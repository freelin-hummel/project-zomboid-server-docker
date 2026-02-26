#!/usr/bin/env python3
"""
validate_maps.py — Pre-flight map/tile conflict checker for PZ dedicated server.

Scans all active workshop mod directories and reports:
  1. Tiledef fileNumber conflicts  — multiple mods claiming the same tile pack ID
  2. Map coordinate conflicts      — multiple mods placing maps at overlapping
                                     chunk grid cells (from .lotheader files)

Usage:
  python3 scripts/validate_maps.py \\
      --mods-txt      mods.txt \\
      --workshop-root workshop-mods/content/108600

Exit codes:
  0  — no conflicts found
  1  — conflicts found (details printed to stdout)
  2  — usage/input error
"""
from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def parse_workshop_ids(mods_txt: Path) -> list[str]:
    ids: list[str] = []
    seen: set[str] = set()
    with mods_txt.open(encoding="utf-8", errors="replace") as fh:
        for line in fh:
            m = re.match(r"(?i)^workshop\s+id\s*:\s*(\S+)", line.strip())
            if m:
                wid = m.group(1)
                if wid not in seen:
                    ids.append(wid)
                    seen.add(wid)
    return ids


def mod_name_for_dir(item_dir: Path) -> str:
    """Return a human-readable label for a workshop item dir."""
    modinfo = next(item_dir.rglob("mod.info"), None)
    if modinfo:
        for line in modinfo.read_text(encoding="utf-8", errors="replace").splitlines():
            m = re.match(r"(?i)^\s*name\s*=\s*(.+)", line)
            if m:
                return f"{m.group(1).strip()} [{item_dir.name}]"
    return item_dir.name


# ---------------------------------------------------------------------------
# 1. Tiledef fileNumber conflicts
# ---------------------------------------------------------------------------
# PZ tile definition files live at:
#   media/newtiledefinitions/*.tiles
#   media/textures/*.pack   (older format — fileNumber in header comment)
#
# The fileNumber is encoded in the filename for .tiles files:
#   2x_<description>_<NNNN>.tiles  →  fileNumber = NNNN
#   or just  <NNNN>.tiles
#
# For .pack files the fileNumber is the numeric prefix before the first "_".

def check_tiledef_conflicts(
    workshop_root: Path,
    workshop_ids: list[str],
) -> dict[int, list[str]]:
    """
    Returns {fileNumber: [mod_label, ...]} for numbers claimed by >1 workshop item.

    PZ B42 declares tiledef fileNumbers inside ``mod.info`` as lines of the form::

        tiledef=<packName> <number>

    Deduplicates within a single workshop item (42/mod.info vs common/mod.info).
    """
    number_to_mods: dict[int, list[str]] = defaultdict(list)

    for wid in workshop_ids:
        item_dir = workshop_root / wid
        if not item_dir.is_dir():
            continue
        label = mod_name_for_dir(item_dir)
        seen: set[int] = set()
        for modinfo_path in item_dir.rglob("mod.info"):
            for line in modinfo_path.read_text(encoding="utf-8", errors="replace").splitlines():
                m = re.match(r"(?i)^tiledef\s*=\s*\S+\s+(\d+)", line.strip())
                if m:
                    num = int(m.group(1))
                    if num not in seen:
                        number_to_mods[num].append(label)
                        seen.add(num)

    return {n: mods for n, mods in number_to_mods.items() if len(mods) > 1}


# ---------------------------------------------------------------------------
# 2. Map coordinate conflicts
# ---------------------------------------------------------------------------
# .lotheader files live at  media/maps/<MapName>/<cx>_<cy>.lotheader
# where cx, cy are chunk-grid coordinates.
# Two mods conflict if they both provide a file for the same (cx, cy).

def check_map_conflicts(
    workshop_root: Path,
    workshop_ids: list[str],
) -> dict[tuple[int, int], list[str]]:
    """
    Returns {(cx, cy): [mod_label, ...]} for chunk coords claimed by >1 mod.
    """
    coord_to_mods: dict[tuple[int, int], list[str]] = defaultdict(list)

    for wid in workshop_ids:
        item_dir = workshop_root / wid
        if not item_dir.is_dir():
            continue
        label = mod_name_for_dir(item_dir)

        seen_coords: set[tuple[int, int]] = set()
        for lh in item_dir.rglob("*.lotheader"):
            m = re.match(r"^(\d+)_(\d+)\.lotheader$", lh.name)
            if m:
                coord = (int(m.group(1)), int(m.group(2)))
                if coord not in seen_coords:
                    coord_to_mods[coord].append(label)
                    seen_coords.add(coord)

    return {c: mods for c, mods in coord_to_mods.items() if len(mods) > 1}


# ---------------------------------------------------------------------------
# 3. Map= entry existence check
# ---------------------------------------------------------------------------
# The server INI Map= key lists map folder names separated by ';'.
# Each name must be provided by at least one active mod (or be a vanilla map).
# Vanilla maps live in the game install dir; we check mod-provided maps only
# and flag anything not found so the operator can investigate.

VANILLA_MAPS = {
    "Muldraugh, KY",
    "Riverside, KY",
    "Rosewood, KY",
    "West Point, KY",
    "Louisville, KY",
}


def collect_provided_maps(
    workshop_root: Path,
    workshop_ids: list[str],
) -> dict[str, list[str]]:
    """
    Returns {map_folder_name: [mod_label, ...]} for every media/maps/* dir
    found across all active workshop items.  Each item is counted only once
    per map name even if it has maps under both 42/ and common/ subdirs.
    """
    provided: dict[str, list[str]] = defaultdict(list)
    for wid in workshop_ids:
        item_dir = workshop_root / wid
        if not item_dir.is_dir():
            continue
        label = mod_name_for_dir(item_dir)
        seen: set[str] = set()
        for maps_dir in item_dir.rglob("media/maps"):
            if maps_dir.is_dir():
                for map_dir in maps_dir.iterdir():
                    if map_dir.is_dir() and map_dir.name not in seen:
                        provided[map_dir.name].append(label)
                        seen.add(map_dir.name)
    return provided


def check_map_entries(
    ini_path: Path,
    workshop_root: Path,
    workshop_ids: list[str],
) -> tuple[list[str], dict[str, list[str]]]:
    """
    Returns:
      - missing: map names listed in Map= with no provider mod on disk
      - duplicate_providers: map names provided by >1 mod (warning, not error)
    """
    if not ini_path.exists():
        return [], {}

    map_entries: list[str] = []
    with ini_path.open(encoding="utf-8", errors="replace") as fh:
        for line in fh:
            if re.match(r"(?i)^Map\s*=", line.strip()):
                raw = line.split("=", 1)[1].strip().rstrip("\r\n")
                map_entries = [e.strip() for e in raw.split(";") if e.strip()]
                break

    if not map_entries:
        return [], {}

    provided = collect_provided_maps(workshop_root, workshop_ids)

    missing = [
        name for name in map_entries
        if name not in VANILLA_MAPS and name not in provided
    ]
    duplicates = {
        name: provided[name]
        for name in map_entries
        if name not in VANILLA_MAPS and len(provided.get(name, [])) > 1
    }
    return missing, duplicates


# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

def print_map_entries_report(
    missing: list[str],
    duplicates: dict[str, list[str]],
) -> None:
    if missing:
        print(f"\n{'='*60}")
        print(f"MAP= MISSING ENTRIES: {len(missing)} map(s) listed in Map= have no provider mod on disk")
        print(f"{'='*60}")
        for name in missing:
            print(f"  - {name!r}")
    if duplicates:
        print(f"\n{'='*60}")
        print(f"MAP= DUPLICATE PROVIDERS: {len(duplicates)} map(s) provided by multiple mods (may conflict)")
        print(f"{'='*60}")
        for name, mods in sorted(duplicates.items()):
            print(f"\n  {name!r}:")
            for mod in mods:
                print(f"    - {mod}")


def print_tiledef_report(conflicts: dict[int, list[str]]) -> None:
    print(f"\n{'='*60}")
    print(f"TILEDEF CONFLICTS: {len(conflicts)} file number(s) claimed by multiple mods")
    print(f"{'='*60}")
    for num in sorted(conflicts):
        mods = conflicts[num]
        print(f"\n  fileNumber {num}  ({len(mods)} mods):")
        for mod in mods:
            print(f"    - {mod}")


def print_map_report(conflicts: dict[tuple[int, int], list[str]]) -> None:
    print(f"\n{'='*60}")
    print(f"MAP COORDINATE CONFLICTS: {len(conflicts)} chunk(s) claimed by multiple mods")
    print(f"{'='*60}")
    # Group by mod pairs for readability
    pair_chunks: dict[frozenset, list[tuple[int, int]]] = defaultdict(list)
    for coord, mods in conflicts.items():
        pair_chunks[frozenset(mods)].append(coord)

    for mod_set, coords in sorted(pair_chunks.items(), key=lambda x: -len(x[1])):
        mod_list = sorted(mod_set)
        print(f"\n  {len(coords)} chunk(s) overlap between:")
        for mod in mod_list:
            print(f"    - {mod}")
        sample = sorted(coords)[:5]
        print(f"  Sample coords: {', '.join(f'({x},{y})' for x,y in sample)}"
              + (" ..." if len(coords) > 5 else ""))


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    ap = argparse.ArgumentParser(description="Pre-flight map/tile conflict checker")
    ap.add_argument("--mods-txt",      required=True, help="Path to mods.txt")
    ap.add_argument("--workshop-root", required=True, help="Path to workshop/content/<appid> dir")
    ap.add_argument("--ini",           default="",    help="Path to default.ini (for Map= check)")
    ap.add_argument("--no-tiledef",    action="store_true", help="Skip tiledef check")
    ap.add_argument("--no-map",        action="store_true", help="Skip map coordinate check")
    ap.add_argument("--no-mapcheck",   action="store_true", help="Skip Map= entry existence check")
    args = ap.parse_args()

    mods_txt = Path(args.mods_txt)
    workshop_root = Path(args.workshop_root)

    if not mods_txt.exists():
        print(f"ERROR: mods.txt not found: {mods_txt}", file=sys.stderr)
        sys.exit(2)
    if not workshop_root.is_dir():
        print(f"ERROR: workshop root not found: {workshop_root}", file=sys.stderr)
        sys.exit(2)

    workshop_ids = parse_workshop_ids(mods_txt)
    on_disk = [wid for wid in workshop_ids if (workshop_root / wid).is_dir()]
    print(f"Scanning {len(on_disk)}/{len(workshop_ids)} workshop items on disk...")

    found_conflicts = False

    if not args.no_tiledef:
        tiledef_conflicts = check_tiledef_conflicts(workshop_root, workshop_ids)
        if tiledef_conflicts:
            print_tiledef_report(tiledef_conflicts)
            found_conflicts = True
        else:
            print("Tiledef fileNumbers: OK (no conflicts)")

    if not args.no_map:
        map_conflicts = check_map_conflicts(workshop_root, workshop_ids)
        if map_conflicts:
            print_map_report(map_conflicts)
            found_conflicts = True
        else:
            print("Map chunk coords:    OK (no conflicts)")

    if not args.no_mapcheck:
        ini_path = Path(args.ini) if args.ini else None
        if ini_path and ini_path.exists():
            missing_maps, dup_maps = check_map_entries(ini_path, workshop_root, workshop_ids)
            if missing_maps or dup_maps:
                print_map_entries_report(missing_maps, dup_maps)
                if missing_maps:
                    found_conflicts = True
            else:
                print("Map= entries:        OK (all maps provided)")
        else:
            print("Map= entries:        skipped (no --ini provided)")

    if found_conflicts:
        print("\nConflicts found — resolve before starting the server to avoid "
              "WorldDictionary corruption.")
        sys.exit(1)
    else:
        print("\nAll checks passed.")
        sys.exit(0)


if __name__ == "__main__":
    main()
