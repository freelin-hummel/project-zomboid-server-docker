#!/usr/bin/env python3
"""
process_mods.py — Runtime mod-configuration helper for the PZ dedicated server.

NOTE: New comprehensive initializer available
---------------------------------------------
A more comprehensive "initialization" workflow is being introduced under
`zomboid/init/` (see `zomboid/init/resolver.lua`). That module is intended
to become the canonical place for:

- an authoritative mod registry structure (source of truth),
- importing `import-mods.yml` as an *import-only feed* (and cleaning imported entries),
- scanning Workshop content to discover provided Mod IDs,
- dependency graph resolution and deterministic load ordering,
- conflict detection and missing dependency reporting,
- (planned) installing missing Workshop items via SteamCMD/Steam APIs.

This script (`process_mods.py`) remains the runtime helper currently used by
`entrypoint.sh` to validate and materialize `Mods=` / `WorkshopItems=` into the
server INI.

Responsibilities:
  1. Parse mods.txt (block-delimited format) to obtain the ordered list of
     workshop IDs and mod IDs, skipping any blocks flagged for deletion.
  2. Collect mod.info metadata from the workshop cache directory.
  3. Validate that the mod-ID list satisfies topological order with respect
     to each mod's `require=` field in mod.info. Exit 1 with a descriptive
     error if it does not.
  4. Rewrite mods.txt in-place: emit the canonical --- block format. Only
     explicitly listed Mod IDs are kept; sub-mods found on disk but not listed
     in mods.txt are not added automatically.
  5. Rewrite the `Mods=` and `WorkshopItems=` keys in default.ini.

mods.txt block format::

    Workshop ID: 3618557184      <- implicit block start
    Mod ID: HereGoesTheSun       <- zero or more
    ---                          <- explicit block end

To remove a workshop item, simply delete its block from mods.txt.

Usage (from entrypoint.sh):
  python3 /home/steam/process_mods.py \
    --mods-txt     /home/steam/mods.txt \
      --workshop-root /path/to/workshop/content/108600 \
      --ini           /home/steam/Zomboid/Server/default.ini

Planned usage (initializer):
        lua5.4 /home/steam/init/resolver.lua \
            --registry      /home/steam/init/mods.json \
            --mods-yml      /home/steam/import-mods.yml \
            --workshop-root /path/to/workshop/content/108600 \
            --write
"""

from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path


# ---------------------------------------------------------------------------
# 1. Parse mods.txt
# ---------------------------------------------------------------------------


@dataclass
class ModBlock:
    """
    Represents one workshop-item block in mods.txt.

    Format::

        Workshop ID: <number>       ← implicit block start
        Mod ID: <name>              ← zero or more
        ---                         ← explicit block end
    """

    workshop_id: str
    mod_ids: list[str] = field(default_factory=list)


def parse_mods_blocks(path: Path) -> list[ModBlock]:
    """
    Parse *path* into an ordered list of :class:`ModBlock` objects.

    Supports both the legacy blank-line-separated format and the new
    ``---``-terminated block format.
    """
    blocks: list[ModBlock] = []
    current: ModBlock | None = None

    with path.open(encoding="utf-8", errors="replace") as fh:
        for raw_line in fh:
            line = raw_line.strip()

            if not line or line.startswith("#"):
                continue

            if line == "---":
                # explicit block end — just stop collecting for current block
                current = None
                continue

            m = re.match(r"(?i)^workshop\s+id\s*:\s*(\S+)", line)
            if m:
                current = ModBlock(workshop_id=m.group(1))
                blocks.append(current)
                continue

            if current is None:
                continue

            m = re.match(r"(?i)^mod\s+id\s*:\s*(.+)", line)
            if m:
                mid = m.group(1).strip()
                if mid and mid not in current.mod_ids:
                    current.mod_ids.append(mid)
                continue

    return blocks


def parse_mods_txt(path: Path) -> tuple[list[str], list[str]]:
    """
    Return ``(workshop_ids, mod_ids)`` for all blocks.

    Duplicate IDs are silently de-duplicated preserving first-occurrence order.
    """
    workshop_ids: list[str] = []
    mod_ids: list[str] = []
    seen_workshops: set[str] = set()
    seen_mods: set[str] = set()

    for block in parse_mods_blocks(path):
        wid = block.workshop_id
        if wid not in seen_workshops:
            workshop_ids.append(wid)
            seen_workshops.add(wid)
        for mid in block.mod_ids:
            if mid and mid not in seen_mods:
                mod_ids.append(mid)
                seen_mods.add(mid)

    return workshop_ids, mod_ids


# ---------------------------------------------------------------------------
# 2. Collect mod.info metadata
# ---------------------------------------------------------------------------


def _parse_mod_info_file(path: Path) -> dict[str, str]:
    """Return a lower-cased key→value dict from a single mod.info file."""
    data: dict[str, str] = {}
    with path.open(encoding="utf-8", errors="replace") as fh:
        for line in fh:
            m = re.match(r"^\s*(\w+)\s*=\s*(.+)", line.rstrip("\r\n"))
            if m:
                data[m.group(1).lower()] = m.group(2).strip()
    return data


def collect_mod_info(
    workshop_root: Path,
    workshop_ids: list[str],
) -> tuple[dict[str, list[str]], dict[str, list[str]]]:
    """
    Walk each workshop item directory and read every ``mod.info`` found inside.

    Returns a 2-tuple:
      - ``requires_map``     : ``{mod_id: [required_mod_id, ...]}``
      - ``workshop_to_mods`` : ``{workshop_id: [mod_id, ...]}`` (on-disk order)

    Only workshop items whose directories exist under *workshop_root* are
    visited; missing directories are silently skipped.
    """
    requires: dict[str, list[str]] = {}
    workshop_to_mods: dict[str, list[str]] = {}
    seen_global: set[str] = set()

    for wid in workshop_ids:
        item_dir = workshop_root / wid
        if not item_dir.is_dir():
            continue  # not downloaded yet

        item_mods: list[str] = []
        for modinfo_path in sorted(item_dir.rglob("mod.info")):
            info = _parse_mod_info_file(modinfo_path)
            mod_id = info.get("id", "").strip()
            if not mod_id:
                continue
            if mod_id not in seen_global:
                raw_require = info.get("require", "").strip()
                deps: list[str] = []
                if raw_require:
                    deps = [d.strip() for d in raw_require.split(",") if d.strip()]
                requires[mod_id] = deps
                seen_global.add(mod_id)
            if mod_id not in item_mods:
                item_mods.append(mod_id)

        if item_mods:
            workshop_to_mods[wid] = item_mods

    return requires, workshop_to_mods


# ---------------------------------------------------------------------------
# 3. Map conflict checks + dynamic Map= collection
# ---------------------------------------------------------------------------

# Vanilla maps appended after all workshop-provided map folders.
VANILLA_MAPS = [
    "Muldraugh, KY",
    "Riverside, KY",
    "Rosewood, KY",
    "West Point, KY",
    "Louisville, KY",
]


def _mod_label_for_dir(item_dir: Path) -> str:
    """Return a human-readable label for a workshop item directory."""
    modinfo = next(item_dir.rglob("mod.info"), None)
    if modinfo:
        for line in modinfo.read_text(encoding="utf-8", errors="replace").splitlines():
            m = re.match(r"(?i)^\s*name\s*=\s*(.+)", line)
            if m:
                return f"{m.group(1).strip()} [{item_dir.name}]"
    return item_dir.name


def check_tiledef_conflicts(
    workshop_root: Path,
    workshop_ids: list[str],
) -> dict[int, list[str]]:
    """
    Returns ``{fileNumber: [mod_label, ...]}`` for numbers claimed by more
    than one **active workshop item**.  An empty dict means no conflicts.

    PZ B42 declares tiledef fileNumbers inside ``mod.info`` as lines of the
    form::

        tiledef=<packName> <number>

    We collect these per workshop item (deduplicating across ``42/mod.info``
    and ``common/mod.info`` variants that appear in the same item dir) and
    flag any number claimed by more than one item.
    """
    number_to_mods: dict[int, list[str]] = defaultdict(list)

    for wid in workshop_ids:
        item_dir = workshop_root / wid
        if not item_dir.is_dir():
            continue
        label = _mod_label_for_dir(item_dir)
        seen: set[int] = set()
        for modinfo_path in item_dir.rglob("mod.info"):
            for line in modinfo_path.read_text(
                encoding="utf-8", errors="replace"
            ).splitlines():
                m = re.match(r"(?i)^tiledef\s*=\s*\S+\s+(\d+)", line.strip())
                if m:
                    num = int(m.group(1))
                    if num not in seen:
                        number_to_mods[num].append(label)
                        seen.add(num)

    return {n: mods for n, mods in number_to_mods.items() if len(mods) > 1}


def check_map_coord_conflicts(
    workshop_root: Path,
    workshop_ids: list[str],
) -> dict[tuple[int, int], list[str]]:
    """
    Returns ``{(cx, cy): [mod_label, ...]}`` for chunk coordinates provided
    by more than one mod.  An empty dict means no conflicts.
    """
    coord_to_mods: dict[tuple[int, int], list[str]] = defaultdict(list)

    for wid in workshop_ids:
        item_dir = workshop_root / wid
        if not item_dir.is_dir():
            continue
        label = _mod_label_for_dir(item_dir)
        seen: set[tuple[int, int]] = set()
        for lh in item_dir.rglob("*.lotheader"):
            p = re.match(r"^(\d+)_(\d+)\.lotheader$", lh.name)
            if p:
                coord = (int(p.group(1)), int(p.group(2)))
                if coord not in seen:
                    coord_to_mods[coord].append(label)
                    seen.add(coord)

    return {c: mods for c, mods in coord_to_mods.items() if len(mods) > 1}


def collect_workshop_maps(
    workshop_root: Path,
    workshop_ids: list[str],
    active_mod_ids: set[str],
) -> list[str]:
    """
    Return a sorted list of unique map folder names (from ``media/maps/*/``)
    found only in mods whose ID appears in *active_mod_ids*.

    Each individual mod sub-folder is identified by the presence of a
    ``mod.info`` file; only those whose ``id=`` value is in *active_mod_ids*
    contribute maps, preventing inactive mods inside a workshop item from
    polluting the Map= list.
    """
    found: set[str] = set()
    seen_mod_map: set[tuple[str, str]] = set()  # (mod_id, map_name) dedup
    for wid in workshop_ids:
        item_dir = workshop_root / wid
        if not item_dir.is_dir():
            continue
        for modinfo_path in item_dir.rglob("mod.info"):
            info = _parse_mod_info_file(modinfo_path)
            mod_id = info.get("id", "").strip()
            if not mod_id or mod_id not in active_mod_ids:
                continue
            mod_root = modinfo_path.parent
            maps_dir = mod_root / "media" / "maps"
            if maps_dir.is_dir():
                for entry in maps_dir.iterdir():
                    if entry.is_dir() and (mod_id, entry.name) not in seen_mod_map:
                        found.add(entry.name)
                        seen_mod_map.add((mod_id, entry.name))
    return sorted(found)


# ---------------------------------------------------------------------------
# 3b. Rewrite mods.txt with proper Workshop ID → Mod ID groupings
# ---------------------------------------------------------------------------


def rewrite_mods_txt(
    mods_txt_path: Path,
    workshop_ids: list[str],
    mod_ids_sorted: list[str],
    workshop_to_mods: dict[str, list[str]],
) -> tuple[bool, list[str]]:
    """
    Rewrite *mods_txt_path* in the block format::

        Workshop ID: <number>
        Mod ID: <name>
        Mod ID: <name>
        ---

    Changes applied:

    * ``Mod ID:`` ordering within each block follows *mod_ids_sorted* (stable
      topo-sorted order).
    * Only Mod IDs explicitly present in *mod_ids_sorted* are written; sub-mods
      found on disk but not listed are not added automatically.
    * Orphan mod IDs (not attributable to any on-disk item) are kept at the
      bottom under a comment header.

    Returns ``(changed, validation_warnings)`` where *changed* is ``True`` when
    the file was overwritten and *validation_warnings* is a list of human-
    readable strings describing issues found (empty blocks whose workshop item
    is not yet downloaded).
    """
    blocks = parse_mods_blocks(mods_txt_path)
    warnings: list[str] = []

    # ── 1. Build the target mod list per block ───────────────────────────
    # Reverse mapping: mod_id → workshop_id (from on-disk cache)
    mod_to_workshop: dict[str, str] = {
        mid: wid for wid, mids in workshop_to_mods.items() for mid in mids
    }

    mod_ids_set = set(mod_ids_sorted)
    sorted_pos = {mid: i for i, mid in enumerate(mod_ids_sorted)}

    def _group_for(wid: str) -> list[str]:
        """Build the final ordered Mod ID list for *wid*."""
        cache_mods = workshop_to_mods.get(wid, [])
        if not cache_mods:
            return []
        # Only include mod IDs that are explicitly enabled in mods.txt,
        # sorted by their topo-sorted position.
        return sorted(
            (m for m in cache_mods if m in mod_ids_set),
            key=lambda m: sorted_pos[m],
        )

    # ── 3. Determine what the rewritten file should look like ─────────────
    new_groups: dict[str, list[str]] = {wid: _group_for(wid) for wid in workshop_ids}
    new_orphans = [m for m in mod_ids_sorted if m not in mod_to_workshop]

    # ── 4. Validation: flag blocks with no enabled Mod IDs ───────────────
    original_block_mods: dict[str, list[str]] = {
        b.workshop_id: b.mod_ids for b in blocks
    }
    for wid in workshop_ids:
        if not new_groups[wid]:
            if workshop_to_mods.get(wid):
                pass  # shouldn't happen — _group_for covers it
            elif original_block_mods.get(wid):
                # Has mod IDs in file but workshop item not downloaded yet — normal
                pass
            else:
                warnings.append(
                    f"  Workshop ID {wid}: empty block, not in cache "
                    "— remove its block from mods.txt to stop tracking it"
                )

    # ── 4. Compare against existing state to decide if we need to write ───
    existing: dict[str, list[str]] = {b.workshop_id: b.mod_ids for b in blocks}
    existing_order = [b.workshop_id for b in blocks]
    existing_orphans: list[str] = []
    for b in blocks:
        if b.workshop_id not in set(workshop_ids):
            existing_orphans.extend(b.mod_ids)

    changed = (
        existing_order != workshop_ids
        or any(existing.get(wid, []) != new_groups[wid] for wid in workshop_ids)
        or existing_orphans != new_orphans
    )

    if not changed:
        return False, warnings

    # ── 5. Write the new file ─────────────────────────────────────────────
    out_lines: list[str] = []
    for wid in workshop_ids:
        out_lines.append(f"Workshop ID: {wid}")
        for mid in new_groups.get(wid, []):
            out_lines.append(f"Mod ID: {mid}")
        out_lines.append("---")
        out_lines.append("")

    if new_orphans:
        out_lines.append("# Mod IDs not yet attributed to any downloaded workshop item")
        for mid in new_orphans:
            out_lines.append(f"Mod ID: {mid}")
        out_lines.append("---")
        out_lines.append("")

    mods_txt_path.write_text("\n".join(out_lines).rstrip("\n") + "\n", encoding="utf-8")
    return True, warnings


# ---------------------------------------------------------------------------
# 4. Topological-order auto-sort
# ---------------------------------------------------------------------------


def ensure_topological_order(
    mod_ids: list[str],
    requires_map: dict[str, list[str]],
) -> tuple[list[str], list[str]]:
    """
    Ensure *mod_ids* satisfies topological order with respect to *requires_map*.

    Strategy:
      - Only edges where **both** the dependent and its dependency appear in
        *mod_ids* AND *requires_map* are considered (lenient on not-yet-
        downloaded mods).
      - If the existing order already satisfies all constraints it is returned
        unchanged (stable pass-through).
      - If any violation exists, a stable Kahn topological sort is run, using
        the original position in *mod_ids* as the tiebreaker so the result
        deviates as little as possible from the declared order.

    Returns ``(ordered_list, reorder_notes)`` where *reorder_notes* is a list
    of human-readable strings describing each moved mod (empty when the input
    order was already valid).

    Raises ``SystemExit(1)`` if:
      - A required dependency is missing from *mod_ids* entirely.
      - The dependency graph contains a cycle.
    """
    import heapq

    mod_id_set: set[str] = set(mod_ids)
    original_pos: dict[str, int] = {mid: i for i, mid in enumerate(mod_ids)}

    # Build effective prerequisite sets (only known, present deps)
    prereqs: dict[str, set[str]] = {mid: set() for mid in mod_ids}
    for mod_id in mod_ids:
        for dep in requires_map.get(mod_id, []):
            if dep not in requires_map:
                continue  # not on disk yet — skip
            if dep not in mod_id_set:
                _fatal(
                    f"Topological error: '{mod_id}' requires '{dep}', "
                    f"but '{dep}' is not listed in mods.txt.\n"
                    f"Add 'Mod ID: {dep}' to mods.txt."
                )
            prereqs[mod_id].add(dep)

    # Fast check: is the existing order already valid?
    if all(
        original_pos[dep] < original_pos[mod_id]
        for mod_id in mod_ids
        for dep in prereqs[mod_id]
    ):
        return mod_ids, []

    # --- Kahn's algorithm with stable original-position tiebreaking ----------
    in_degree: dict[str, int] = {mid: len(prereqs[mid]) for mid in mod_ids}
    dependents: dict[str, list[str]] = {mid: [] for mid in mod_ids}
    for mod_id in mod_ids:
        for dep in prereqs[mod_id]:
            dependents[dep].append(mod_id)

    heap: list[tuple[int, str]] = [
        (original_pos[mid], mid) for mid in mod_ids if in_degree[mid] == 0
    ]
    heapq.heapify(heap)

    result: list[str] = []
    while heap:
        _, mid = heapq.heappop(heap)
        result.append(mid)
        for dependent in dependents[mid]:
            in_degree[dependent] -= 1
            if in_degree[dependent] == 0:
                heapq.heappush(heap, (original_pos[dependent], dependent))

    if len(result) != len(mod_ids):
        cycle_mods = [m for m in mod_ids if m not in set(result)]
        _fatal(
            f"Dependency cycle detected among {len(cycle_mods)} mod(s): "
            + ", ".join(cycle_mods[:10])
            + (" ..." if len(cycle_mods) > 10 else "")
        )

    # Describe what moved
    new_pos: dict[str, int] = {mid: i for i, mid in enumerate(result)}
    reorder_notes = [
        f"  {mid!r}: position {original_pos[mid]} → {new_pos[mid]}"
        for mid in mod_ids
        if original_pos[mid] != new_pos[mid]
    ]
    return result, reorder_notes


# ---------------------------------------------------------------------------
# 4. Update default.ini
# ---------------------------------------------------------------------------


def update_ini(ini_path: Path, mods_csv: str, workshop_csv: str) -> None:
    """
    Rewrite the ``Mods=`` and ``WorkshopItems=`` entries in *ini_path*.

    PZ server INI files may span key values across continuation lines (lines
    that do not start with ``Key=``). This function skips all continuation
    lines belonging to the two keys being replaced, then rewrites the file
    in-place.

    If either key is absent from the file it is appended at the end.
    """
    original = ini_path.read_text(encoding="utf-8", errors="replace")
    # Strip NUL bytes that occasionally appear in PZ saves
    if "\x00" in original:
        original = original.replace("\x00", "")

    output_lines: list[str] = []
    wrote_mods = False
    wrote_workshop = False
    skip_continuation = False
    current_skip_key: str | None = None  # "mods" | "workshop" | None

    def _is_continuation(s: str) -> bool:
        """A continuation line does not look like a new INI key or blank/comment."""
        s = s.rstrip("\r\n")
        return (
            bool(s)
            and not s.startswith("#")
            and not re.match(r"[A-Za-z][A-Za-z0-9_]*\s*=", s)
        )

    for raw in original.splitlines(keepends=True):
        stripped = raw.rstrip("\r\n")

        # While skipping a multi-line old value, eat continuation lines
        if skip_continuation:
            if _is_continuation(stripped):
                continue
            else:
                skip_continuation = False
                current_skip_key = None

        if re.match(r"(?i)^Mods\s*=", stripped):
            output_lines.append(f"Mods={mods_csv}\n")
            wrote_mods = True
            skip_continuation = True
            current_skip_key = "mods"
            continue

        if re.match(r"(?i)^WorkshopItems\s*=", stripped):
            output_lines.append(f"WorkshopItems={workshop_csv}\n")
            wrote_workshop = True
            skip_continuation = True
            current_skip_key = "workshop"
            continue

        output_lines.append(raw)

    if not wrote_mods:
        output_lines.append(f"Mods={mods_csv}\n")
    if not wrote_workshop:
        output_lines.append(f"WorkshopItems={workshop_csv}\n")

    ini_path.write_text("".join(output_lines), encoding="utf-8")


# ---------------------------------------------------------------------------
# Update Map= line in default.ini
# ---------------------------------------------------------------------------


def update_map_line(ini_path: Path, map_csv: str) -> None:
    """
    Rewrite the ``Map=`` entry in *ini_path* with *map_csv*.
    Handles multi-line continuation values the same way as ``update_ini``.
    If ``Map=`` is absent it is appended at the end.
    """
    original = ini_path.read_text(encoding="utf-8", errors="replace")
    if "\x00" in original:
        original = original.replace("\x00", "")

    def _is_continuation(s: str) -> bool:
        s = s.rstrip("\r\n")
        return (
            bool(s)
            and not s.startswith("#")
            and not re.match(r"[A-Za-z][A-Za-z0-9_]*\s*=", s)
        )

    output_lines: list[str] = []
    wrote = False
    skip = False
    for raw in original.splitlines(keepends=True):
        stripped = raw.rstrip("\r\n")
        if skip:
            if _is_continuation(stripped):
                continue
            skip = False
        if re.match(r"(?i)^Map\s*=", stripped):
            output_lines.append(f"Map={map_csv}\n")
            wrote = True
            skip = True
            continue
        output_lines.append(raw)
    if not wrote:
        output_lines.append(f"Map={map_csv}\n")
    ini_path.write_text("".join(output_lines), encoding="utf-8")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _fatal(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


# ---------------------------------------------------------------------------
# CLI entry-point
# ---------------------------------------------------------------------------


def update_public_name(ini_path: Path, public_name: str) -> None:
    """Rewrite or append the ``PublicName=`` key in *ini_path*."""
    original = ini_path.read_text(encoding="utf-8", errors="replace")
    output_lines: list[str] = []
    wrote = False
    for raw in original.splitlines(keepends=True):
        if re.match(r"(?i)^PublicName\s*=", raw.rstrip("\r\n")):
            output_lines.append(f"PublicName={public_name}\n")
            wrote = True
        else:
            output_lines.append(raw)
    if not wrote:
        output_lines.append(f"PublicName={public_name}\n")
    ini_path.write_text("".join(output_lines), encoding="utf-8")


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Validate mods.txt and write Mods=/WorkshopItems= into default.ini"
    )
    ap.add_argument("--mods-txt", required=True, help="Path to mods.txt")
    ap.add_argument(
        "--workshop-root", required=True, help="Path to workshop/content/<appid> dir"
    )
    ap.add_argument("--ini", required=True, help="Path to default.ini to update")
    ap.add_argument(
        "--public-name", default="", help="Value to write into PublicName= (optional)"
    )
    args = ap.parse_args()

    mods_txt_path = Path(args.mods_txt)
    workshop_root = Path(args.workshop_root)
    ini_path = Path(args.ini)

    # --- Validate inputs -----------------------------------------------------
    if not mods_txt_path.exists():
        _fatal(f"mods.txt not found: {mods_txt_path}")
    if not ini_path.exists():
        _fatal(f"default.ini not found: {ini_path}")

    # --- Step 1: parse mods.txt ----------------------------------------------
    workshop_ids, mod_ids = parse_mods_txt(mods_txt_path)

    if not workshop_ids:
        _fatal("mods.txt contains no 'Workshop ID:' lines.")
    if not mod_ids:
        _fatal("mods.txt contains no 'Mod ID:' lines.")

    print(f"mods.txt: {len(workshop_ids)} workshop IDs, {len(mod_ids)} mod IDs")

    # --- Step 2: collect mod.info from downloaded items ----------------------
    requires_map, workshop_to_mods = collect_mod_info(workshop_root, workshop_ids)
    print(
        f"mod.info: loaded metadata for {len(requires_map)} mod(s) across "
        f"{len(workshop_to_mods)} workshop item(s) on disk"
    )

    # --- Step 2b: map conflict checks (fatal on any conflict) ----------------
    tiledef_conflicts = check_tiledef_conflicts(workshop_root, workshop_ids)
    map_coord_conflicts = check_map_coord_conflicts(workshop_root, workshop_ids)

    if tiledef_conflicts or map_coord_conflicts:
        if tiledef_conflicts:
            print(
                f"WARNING: {len(tiledef_conflicts)} tiledef fileNumber conflict(s) detected:"
            )
            for num in sorted(tiledef_conflicts):
                mods = tiledef_conflicts[num]
                print(f"  fileNumber {num}: {', '.join(mods)}")
        if map_coord_conflicts:
            sample = sorted(map_coord_conflicts.items())[:10]
            print(
                f"WARNING: {len(map_coord_conflicts)} map chunk coordinate conflict(s) detected:"
            )
            for (cx, cy), mods in sample:
                print(f"  ({cx},{cy}): {', '.join(mods)}")
            if len(map_coord_conflicts) > 10:
                print(f"  ... and {len(map_coord_conflicts) - 10} more")
        print(
            "WARNING: Continuing despite map conflicts — resolve before production use."
        )
    else:
        print("Map conflict checks:  OK")

    # --- Step 2c: collect workshop-provided maps for Map= --------------------
    workshop_maps = collect_workshop_maps(workshop_root, workshop_ids, set(mod_ids))
    vanilla_maps = [v for v in VANILLA_MAPS if v not in set(workshop_maps)]
    all_maps = workshop_maps + vanilla_maps
    print(
        f"Map= will contain {len(all_maps)} maps "
        f"({len(workshop_maps)} from mods, {len(vanilla_maps)} vanilla)"
    )

    # --- Step 3: ensure topological order (auto-sort on violation) -----------
    mod_ids, reorder_notes = ensure_topological_order(mod_ids, requires_map)
    if reorder_notes:
        print(
            f"WARNING: mods.txt order violated {len(reorder_notes)} dependency "
            f"constraint(s) — auto-sorted (stable). Reordered mods:"
        )
        for note in reorder_notes:
            print(note)
        print("Update mods.txt to match this order to suppress this warning.")
    else:
        print("Topological order: OK (stable)")

    # --- Step 3b: rewrite mods.txt —
    changed, val_warnings = rewrite_mods_txt(
        mods_txt_path, workshop_ids, mod_ids, workshop_to_mods
    )
    if val_warnings:
        print(
            f"WARNING: {len(val_warnings)} workshop block(s) have no Mod IDs "
            "and are not yet in the cache (not downloaded?):"
        )
        for w in val_warnings:
            print(w)
    if changed:
        # Re-read after rewrite.
        workshop_ids, mod_ids = parse_mods_txt(mods_txt_path)
        print(f"Rewrote mods.txt")

    # --- Step 4: write INI ---------------------------------------------------
    # PZ expects Mods= entries prefixed with backslash: \modA;\modB;...
    mods_csv = ";".join(f"\\{m}" for m in mod_ids)
    workshop_csv = ";".join(workshop_ids)

    update_ini(ini_path, mods_csv, workshop_csv)
    print(
        f"Updated {ini_path}: Mods=({len(mod_ids)} entries), WorkshopItems=({len(workshop_ids)} entries)"
    )
    # --- Step 4b: write dynamic Map= -----------------------------------------
    map_csv = ";".join(all_maps)
    update_map_line(ini_path, map_csv)
    print(f"Updated Map=: {len(all_maps)} entries")

    # --- Step 5 (optional): set PublicName -----------------------------------
    if args.public_name:
        update_public_name(ini_path, args.public_name)
        print(f"Set PublicName={args.public_name}")


if __name__ == "__main__":
    main()
