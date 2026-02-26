#!/usr/bin/env python3
"""
prune_workshop_manifest.py — Remove stale workshop items from appworkshop_*.acf

When a workshop item directory is deleted, Steam's manifest still has entries
for it in WorkshopItemsInstalled and WorkshopItemDetails.  If those entries
remain, the embedded Steam client may queue re-downloads on next server start.

Usage:
    python3 prune_workshop_manifest.py <acf_path> <keep_id> [<keep_id> ...]

The script rewrites <acf_path> in-place, removing any top-level key blocks
inside "WorkshopItemsInstalled" and "WorkshopItemDetails" whose ID is not in
the keep list.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path


def _parse_blocks(lines: list[str], start: int) -> tuple[dict[str, tuple[int, int]], int]:
    """
    Parse a flat level of ``"key" { ... }`` blocks starting just after the
    opening ``{`` at *start*.  Returns ``(blocks, end_line_idx)`` where
    *blocks* maps key → (first_line, last_line) inclusive line indices of the
    entire ``"key" { ... }`` span, and *end_line_idx* is the index of the
    closing ``}`` of the outer block.
    """
    blocks: dict[str, tuple[int, int]] = {}
    i = start
    depth = 0
    current_key: str | None = None
    block_start: int = 0

    while i < len(lines):
        line = lines[i].rstrip("\r\n")
        stripped = line.strip()

        if stripped == "{":
            if depth == 0 and current_key is not None:
                block_start = i - 1  # include the "key" line before {
            depth += 1
        elif stripped == "}":
            if depth == 1 and current_key is not None:
                blocks[current_key] = (block_start, i)
                current_key = None
            depth -= 1
            if depth < 0:
                return blocks, i
        elif depth == 0:
            m = re.match(r'^\s*"([^"]+)"\s*$', stripped)
            if m:
                current_key = m.group(1)

        i += 1

    return blocks, i


def prune_acf(acf_path: Path, keep_ids: set[str]) -> bool:
    """
    Rewrite *acf_path* removing any item entries not in *keep_ids* from
    ``WorkshopItemsInstalled`` and ``WorkshopItemDetails`` sections.

    Returns True if the file was modified, False if nothing changed.
    """
    text = acf_path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines(keepends=True)

    # Find WorkshopItemsInstalled and WorkshopItemDetails section bounds
    section_starts: dict[str, int] = {}
    for i, line in enumerate(lines):
        m = re.match(r'^\s*"(WorkshopItemsInstalled|WorkshopItemDetails)"\s*$', line.strip())
        if m:
            section_starts[m.group(1)] = i

    if not section_starts:
        return False

    # Collect line ranges to delete (sorted descending so we can delete without
    # shifting indices)
    ranges_to_delete: list[tuple[int, int]] = []

    for section_name, header_idx in section_starts.items():
        # Find the opening { of this section
        open_idx = header_idx + 1
        while open_idx < len(lines) and lines[open_idx].strip() != "{":
            open_idx += 1
        if open_idx >= len(lines):
            continue

        blocks, _ = _parse_blocks(lines, open_idx + 1)
        for item_id, (start, end) in blocks.items():
            if item_id not in keep_ids:
                ranges_to_delete.append((start, end))

    if not ranges_to_delete:
        return False

    # Sort descending so deletions don't shift earlier indices
    ranges_to_delete.sort(key=lambda r: r[0], reverse=True)

    new_lines = lines[:]
    for start, end in ranges_to_delete:
        del new_lines[start:end + 1]

    acf_path.write_text("".join(new_lines), encoding="utf-8")
    return True


def main() -> None:
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <acf_path> [<keep_id> ...]", file=sys.stderr)
        sys.exit(2)

    acf_path = Path(sys.argv[1])
    keep_ids = set(sys.argv[2:])

    if not acf_path.exists():
        print(f"ERROR: {acf_path} not found", file=sys.stderr)
        sys.exit(2)

    if prune_acf(acf_path, keep_ids):
        print(f"Pruned stale entries from {acf_path.name} (kept {len(keep_ids)} items)")
    else:
        print(f"No stale entries in {acf_path.name}")


if __name__ == "__main__":
    main()
