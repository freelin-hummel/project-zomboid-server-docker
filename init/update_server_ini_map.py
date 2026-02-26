#!/usr/bin/env python3
"""
Update a Project Zomboid server INI Map= setting by scanning enabled workshop mods
for `media/maps/*` entries.

Key requirements
----------------
- Scan actual files on disk (not plan-provided map list)
- Only consider maps from mods that are enabled in the mods registry JSON
- Detect conflicts and FAIL:
  - Overlapping tile coverage: two distinct maps claim the same world cell(s) based on
    `.lotheader` coverage (e.g. both contain `49_4.lotheader`, which maps to the same world cell)
- Update ini key:
  - Rewrite (or append) `Map=` in the target ini file
  - Preserve other content; handle multi-line continuation values similarly to other scripts
- Update spawn regions:
  - Generate a server spawnregions lua file from discovered maps (preferring explicit
    `spawnregions.lua` when present, otherwise falling back to `spawnpoints.lua`).

Assumptions / conventions
-------------------------
- Workshop mods are laid out under:
    {workshop_root}/{workshop_appid}/{workshop_id}/...
  and map directories are at:
    .../media/maps/{MapName}/
  with (optionally) `map.info` inside the map folder.

- This environment may include duplicate-case compatibility symlinks (e.g. Windows vs Linux path
  casing). To avoid double-counting maps and falsely reporting overlaps, this script ignores:
  - symlinked map directories under `media/maps/*`
  - symlinked `.lotheader` files (tile coverage scan)
  Only real directories/files are considered as authoritative.

- Map tile coverage is approximated by scanning `*.lotheader` files in the map folder.
  If two maps contain the same `X_Y.lotheader`, they overlap on that tile cell and will be rejected.

- Registry includes enabled workshop IDs in one of:
  plan["mods"]["enabledWorkshopIds"] (preferred)
  plan["mods"]["workshopIds"]
  plan["workshop"]["enabledWorkshopIds"]

Usage
-----
python3 update_server_ini_map.py \
    --registry /data/zomboid/init/mods.json \
  --ini /data/zomboid/data/Server/server.ini \
  --workshop-root /home/steam/project-zomboid-dedicated/steamapps/workshop/content \
  --workshop-appid 108600 \
  --require-map \
  --base-map "Muldraugh, KY" \
  --spawnregions-out /data/zomboid/data/Server/server_spawnregions.lua

Exit codes
----------
0 success
2 invalid inputs / conflicts / requirements not met
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Set, Tuple


def _fatal(msg: str) -> "None":
    print(f"ERROR: {msg}", file=sys.stderr)
    raise SystemExit(2)


def _warn(msg: str) -> None:
    print(f"WARNING: {msg}", file=sys.stderr)


def _load_json(path: Path) -> Dict[str, Any]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        _fatal(f"registry file not found: {path}")
        raise
    except json.JSONDecodeError as e:
        _fatal(f"invalid JSON in registry {path}: {e}")
        raise


def _get_nested(plan: Dict[str, Any], path: Sequence[str]) -> Optional[Any]:
    cur: Any = plan
    for p in path:
        if not isinstance(cur, dict):
            return None
        if p not in cur:
            return None
        cur = cur[p]
    return cur


def _unique_preserve_order(items: Iterable[str]) -> List[str]:
    seen = set()
    out: List[str] = []
    for x in items:
        s = str(x).strip()
        if not s or s in seen:
            continue
        seen.add(s)
        out.append(s)
    return out


def extract_enabled_workshop_ids(plan: Dict[str, Any]) -> List[str]:
    mods_root = plan.get("mods")
    if not isinstance(mods_root, list):
        return []
    out: List[str] = []
    for item in mods_root:
        if not isinstance(item, dict):
            continue
        wid = str(item.get("workshopId", "")).strip()
        enabled_mod_ids = [
            str(m.get("id", "")).strip()
            for m in (item.get("mods") or [])
            if isinstance(m, dict)
            and bool(m.get("enabled", False))
            and str(m.get("id", "")).strip()
        ]
        if wid and enabled_mod_ids and re.fullmatch(r"\d+", wid):
            out.append(wid)
    return _unique_preserve_order(out)



def _is_continuation_line(s: str) -> bool:
    """
    A continuation line does not look like a new INI key, or blank/comment.
    This matches the style used elsewhere in this repo.
    """
    s = s.rstrip("\r\n")
    return (
        bool(s)
        and not s.startswith("#")
        and not re.match(r"[A-Za-z][A-Za-z0-9_]*\s*=", s)
    )


def rewrite_ini_map_key(ini_path: Path, *, map_csv: str) -> None:
    original = ini_path.read_text(encoding="utf-8", errors="replace")
    if "\x00" in original:
        original = original.replace("\x00", "")

    out_lines: List[str] = []
    wrote_map = False

    skipping = False
    for raw in original.splitlines(keepends=True):
        stripped = raw.rstrip("\r\n")

        if skipping:
            if _is_continuation_line(stripped):
                continue
            skipping = False

        if re.match(r"(?i)^Map\s*=", stripped):
            out_lines.append(f"Map={map_csv}\n")
            wrote_map = True
            skipping = True
            continue

        out_lines.append(raw)

    if not wrote_map:
        out_lines.append(f"Map={map_csv}\n")

    ini_path.write_text("".join(out_lines), encoding="utf-8")


def _safe_rel(p: Path, root: Path) -> str:
    try:
        return str(p.relative_to(root))
    except Exception:
        return str(p)


@dataclass(frozen=True)
class MapSource:
    workshop_id: str
    map_name: str
    map_dir: Path
    mod_id: Optional[str] = None


@dataclass(frozen=True)
class MapCellClaim:
    map_name: str
    workshop_id: str
    cell_x: int
    cell_y: int
    source_file: Path


def _is_map_dir(map_dir: Path) -> bool:
    """
    Decide whether a directory looks like a Project Zomboid map folder.

    Prefer `map.info` but allow `.lotheader`-only packages as a fallback.
    """
    if not map_dir.exists() or not map_dir.is_dir():
        return False
    if (map_dir / "map.info").exists():
        return True
    # Fallback: if it contains at least one .lotheader file, treat as a map dir.
    try:
        for p in map_dir.iterdir():
            if p.is_symlink():
                continue
            if p.is_file() and p.suffix.lower() == ".lotheader":
                return True
    except PermissionError as e:
        _fatal(f"permission error scanning map dir {map_dir}: {e}")
    return False


def _discover_map_dirs_recursive(item_root: Path) -> List[Path]:
    """
    Recursively discover map directories under a workshop item root.

    Workshop items commonly nest maps under:
      - mods/<ModName>/media/maps/<MapName>
      - mods/<ModName>/common/media/maps/<MapName>
      - mods/<ModName>/42/media/maps/<MapName>
      - mods/<ModName>/common/42/media/maps/<MapName>

    We search for `media/maps/*` directories anywhere under the item root
    and then validate the leaf directory as an actual map dir.
    """
    out: List[Path] = []
    seen: set[str] = set()

    # Find any directory named "maps" that lives under a "media" parent, then check its children.
    for media_dir in item_root.rglob("media"):
        # Ignore symlinked directories to prevent duplicate-case compatibility links.
        if media_dir.is_symlink():
            continue
        if not media_dir.is_dir():
            continue

        maps_parent = media_dir / "maps"
        if not maps_parent.exists() or not maps_parent.is_dir():
            continue
        if maps_parent.is_symlink():
            continue

        try:
            for child in sorted(maps_parent.iterdir(), key=lambda p: p.name.lower()):
                if child.is_symlink():
                    continue
                if not child.is_dir():
                    continue
                # De-dupe by realpath string to avoid double-counting the same directory reached twice.
                key = str(child.resolve())
                if key in seen:
                    continue
                seen.add(key)

                if _is_map_dir(child):
                    out.append(child)
        except PermissionError as e:
            _fatal(f"permission error scanning {maps_parent}: {e}")

    return out


_MODINFO_ID_RE = re.compile(r"(?i)^id\s*=\s*(.+)$")


def _parse_mod_id_from_mod_info(mod_info_path: Path) -> Optional[str]:
    try:
        with mod_info_path.open("r", encoding="utf-8", errors="replace") as fh:
            for raw_line in fh:
                line = raw_line.strip()
                m = _MODINFO_ID_RE.match(line)
                if not m:
                    continue
                mod_id = m.group(1).strip().lstrip("\\").strip()
                if mod_id:
                    return mod_id
    except FileNotFoundError:
        return None
    except PermissionError as e:
        _fatal(f"permission error reading {mod_info_path}: {e}")
    return None


def _find_owner_mod_id_for_map_dir(map_dir: Path, item_root: Path) -> Optional[str]:
    """
    Best-effort owner Mod ID discovery for a map folder.

    We walk from map_dir up toward the workshop item root and look for likely
    mod.info locations used by PZ mods, e.g.:
      - <mod-root>/mod.info
      - <mod-root>/42.0/mod.info
      - <mod-root>/common/42.0/mod.info
    """
    cur = map_dir
    try:
        item_resolved = item_root.resolve()
    except Exception:
        item_resolved = item_root

    while True:
        candidates = [
            cur / "mod.info",
            cur / "42.0" / "mod.info",
            cur / "common" / "42.0" / "mod.info",
        ]
        for candidate in candidates:
            if not candidate.exists() or not candidate.is_file() or candidate.is_symlink():
                continue
            mod_id = _parse_mod_id_from_mod_info(candidate)
            if mod_id:
                return mod_id

        if cur == cur.parent:
            break
        try:
            if cur.resolve() == item_resolved:
                break
        except Exception:
            if cur == item_root:
                break
        cur = cur.parent

    return None


def discover_maps_for_workshop_item(
    item_root: Path,
    *,
    workshop_id: str,
    enabled_mod_ids: Optional[Set[str]] = None,
) -> List[MapSource]:
    """
    Discover map folders for a workshop item directory by scanning recursively for
    `media/maps/*` and validating each candidate by `map.info` or `.lotheader`.

    NOTE: We ignore symlinked directories to prevent duplicate-case compatibility
    symlinks from being treated as separate maps.
    """
    out: List[MapSource] = []
    for map_dir in _discover_map_dirs_recursive(item_root):
        name = map_dir.name.strip()
        if not name:
            continue
        owner_mod_id = _find_owner_mod_id_for_map_dir(map_dir, item_root)
        if enabled_mod_ids is not None and owner_mod_id and owner_mod_id not in enabled_mod_ids:
            continue
        out.append(
            MapSource(
                workshop_id=workshop_id,
                map_name=name,
                map_dir=map_dir,
                mod_id=owner_mod_id,
            )
        )
    return out


def scan_maps(
    *,
    workshop_root: Path,
    workshop_appid: str,
    workshop_ids: Sequence[str],
    enabled_mod_ids: Optional[Set[str]] = None,
) -> List[MapSource]:
    """
    Scan all enabled workshop items for map folders.
    """
    base = workshop_root / str(workshop_appid)
    if not base.exists():
        _fatal(f"workshop base directory not found: {base}")

    all_sources: List[MapSource] = []
    for wid in workshop_ids:
        item_root = base / str(wid)
        if not item_root.exists():
            _fatal(f"enabled workshop item not found on disk: {item_root}")
        all_sources.extend(
            discover_maps_for_workshop_item(
                item_root,
                workshop_id=str(wid),
                enabled_mod_ids=enabled_mod_ids,
            )
        )

    return all_sources


def extract_enabled_mod_ids(plan: Dict[str, Any]) -> List[str]:
    mods_root = plan.get("mods")
    if not isinstance(mods_root, list):
        return []
    out: List[str] = []
    seen: set[str] = set()
    for item in mods_root:
        if not isinstance(item, dict):
            continue
        for meta in (item.get("mods") or []):
            if not isinstance(meta, dict) or not bool(meta.get("enabled", False)):
                continue
            s = str(meta.get("id", "")).strip()
            if s and s not in seen:
                out.append(s)
                seen.add(s)
    return out



_LOTHEADER_RE = re.compile(r"^(?P<x>-?\d+)_(?P<y>-?\d+)\.lotheader$", re.IGNORECASE)


def _iter_lotheaders(map_dir: Path) -> Iterable[Path]:
    try:
        for p in map_dir.iterdir():
            # Ignore symlinked files to avoid double-counting compatibility links.
            if p.is_symlink():
                continue
            if not p.is_file():
                continue
            if p.suffix.lower() != ".lotheader":
                continue
            yield p
    except FileNotFoundError:
        return
    except PermissionError as e:
        _fatal(f"permission error scanning map dir {map_dir}: {e}")


def discover_cell_claims(map_sources: Sequence[MapSource]) -> List[MapCellClaim]:
    """
    Build a list of world cell claims for each map by reading `X_Y.lotheader` filenames.
    """
    claims: List[MapCellClaim] = []
    for src in map_sources:
        for lh in _iter_lotheaders(src.map_dir):
            m = _LOTHEADER_RE.match(lh.name)
            if not m:
                continue
            try:
                cx = int(m.group("x"))
                cy = int(m.group("y"))
            except ValueError:
                continue
            claims.append(
                MapCellClaim(
                    map_name=src.map_name,
                    workshop_id=src.workshop_id,
                    cell_x=cx,
                    cell_y=cy,
                    source_file=lh,
                )
            )
    return claims


def detect_conflicts(map_sources: Sequence[MapSource]) -> None:
    """
    Fail on overlapping tile positions.

    We treat a conflict as: two distinct maps claim the same (cell_x, cell_y)
    based on `.lotheader` coverage.
    """
    claims = discover_cell_claims(map_sources)

    by_cell: Dict[Tuple[int, int], List[MapCellClaim]] = {}
    for c in claims:
        by_cell.setdefault((c.cell_x, c.cell_y), []).append(c)

    overlaps: List[Tuple[Tuple[int, int], List[MapCellClaim]]] = []
    for cell, cs in by_cell.items():
        # Different maps (or different workshop sources) claiming the same cell
        unique_maps = {(x.map_name, x.workshop_id) for x in cs}
        if len(unique_maps) > 1:
            overlaps.append((cell, cs))

    if overlaps:
        # Keep output bounded but useful
        overlaps_sorted = sorted(overlaps, key=lambda x: (x[0][0], x[0][1]))
        lines = [
            "map overlap conflicts detected (multiple maps claim the same cell via .lotheader):"
        ]
        max_cells = 50
        for idx, (cell, cs) in enumerate(overlaps_sorted[:max_cells], start=1):
            lines.append(f"- cell {cell[0]}_{cell[1]} has {len(cs)} claims:")
            for c in sorted(
                cs,
                key=lambda z: (z.map_name.lower(), z.workshop_id, str(z.source_file)),
            ):
                lines.append(
                    f"    map={c.map_name} workshop_id={c.workshop_id} file={c.source_file}"
                )
        if len(overlaps_sorted) > max_cells:
            lines.append(
                f"... plus {len(overlaps_sorted) - max_cells} more overlapping cells"
            )
        _fatal("\n".join(lines))


def order_maps(
    map_sources: Sequence[MapSource],
    *,
    base_map: str,
    workshop_ids_in_order: Sequence[str],
) -> List[str]:
    """
    Produce final Map= order.

    Rules:
    - Always put base_map first (default: "Muldraugh, KY")
    - Then append discovered map names in the order of workshop_ids provided,
      respecting within-mod alphabetical order (from the scan).
    - De-duplicate while preserving order.
    """
    per_mod: Dict[str, List[str]] = {}
    for src in map_sources:
        per_mod.setdefault(src.workshop_id, []).append(src.map_name)

    ordered: List[str] = [base_map]
    for wid in workshop_ids_in_order:
        names = per_mod.get(str(wid), [])
        ordered.extend(names)

    return _unique_preserve_order(ordered)


def _find_spawnregions_lua(map_dir: Path) -> Optional[Path]:
    p = map_dir / "spawnregions.lua"
    return p if p.exists() and p.is_file() else None


def _find_spawnpoints_lua(map_dir: Path) -> Optional[Path]:
    p = map_dir / "spawnpoints.lua"
    return p if p.exists() and p.is_file() else None


def generate_spawnregions_lua(
    *,
    out_path: Path,
    map_names_ordered: Sequence[str],
) -> None:
    """
    Generate a server spawnregions lua file.

    For each map, prefer:
      media/maps/<MapName>/spawnregions.lua
    else fall back to:
      media/maps/<MapName>/spawnpoints.lua

    The output format matches the common server-side `*_spawnregions.lua` style:
      function SpawnRegions()
          return {
              { name = "...", file = "..." },
              ...
          }
      end
    """
    entries: List[Tuple[str, str]] = []
    for name in map_names_ordered:
        mdir = Path("media") / "maps" / name
        sr = _find_spawnregions_lua(
            Path(out_path.parent.parent) / mdir
        )  # best-effort; may not exist in this FS
        if sr is not None:
            entries.append((name, f"media/maps/{name}/spawnregions.lua"))
            continue
        sp = _find_spawnpoints_lua(Path(out_path.parent.parent) / mdir)  # best-effort
        if sp is not None:
            entries.append((name, f"media/maps/{name}/spawnpoints.lua"))
            continue
        # If neither exists, skip quietly (map may not provide spawns)
        continue

    # Always generate file; empty entries is valid but not useful.
    lines = []
    lines.append("function SpawnRegions()")
    lines.append("\treturn {")
    for name, file_ in entries:
        lines.append(f'\t\t{{ name = "{name}", file = "{file_}" }},')
    lines.append("\t}")
    lines.append("end")
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main(argv: Optional[Sequence[str]] = None) -> int:
    ap = argparse.ArgumentParser(
        description="Scan workshop mods for media/maps and update server.ini Map=, failing on conflicts."
    )
    ap.add_argument(
        "--registry",
        required=True,
        type=Path,
        help="Path to mods.json produced by init resolver",
    )
    ap.add_argument(
        "--ini",
        required=True,
        type=Path,
        help="Path to server.ini (or other profile ini) to update",
    )
    ap.add_argument(
        "--workshop-root",
        required=True,
        type=Path,
        help="Workshop content root that contains the appid directory (e.g. .../steamapps/workshop/content)",
    )
    ap.add_argument(
        "--workshop-appid",
        required=True,
        help="Workshop appid to scan under workshop-root (typically 108600 for Project Zomboid mods)",
    )
    ap.add_argument(
        "--base-map",
        default="Muldraugh, KY",
        help='Base map name to ensure is first (default: "Muldraugh, KY")',
    )
    ap.add_argument(
        "--require-map",
        action="store_true",
        help="Fail if no map folders are discovered in enabled workshop items.",
    )
    ap.add_argument(
        "--spawnregions-out",
        type=Path,
        default=None,
        help="If set, write a spawnregions lua file at this path (e.g. /home/steam/Zomboid/Server/server_spawnregions.lua).",
    )
    ap.add_argument(
        "--verbose",
        action="store_true",
        help="Print discovered map folders and sources.",
    )
    args = ap.parse_args(list(argv) if argv is not None else None)

    plan_path: Path = args.registry
    ini_path: Path = args.ini
    workshop_root: Path = args.workshop_root

    if not plan_path.exists():
        _fatal(f"registry file not found: {plan_path}")
    if not ini_path.exists():
        _fatal(f"ini not found: {ini_path}")
    if not workshop_root.exists():
        _fatal(f"workshop-root not found: {workshop_root}")

    plan = _load_json(plan_path)
    workshop_ids = extract_enabled_workshop_ids(plan)
    enabled_mod_ids = set(extract_enabled_mod_ids(plan))
    if not workshop_ids:
        _fatal("no enabled workshop IDs found in registry; cannot scan for map folders")

    map_sources = scan_maps(
        workshop_root=workshop_root,
        workshop_appid=str(args.workshop_appid),
        workshop_ids=workshop_ids,
        enabled_mod_ids=enabled_mod_ids if enabled_mod_ids else None,
    )

    if args.verbose:
        base = workshop_root / str(args.workshop_appid)
        print(f"Scanning workshop base: {base}")
        for src in map_sources:
            print(
                f"found map={src.map_name} mod_id={src.mod_id or '<unknown>'} workshop_id={src.workshop_id} path={_safe_rel(src.map_dir, base)}"
            )

    # Conflict detection (tile overlap)
    detect_conflicts(map_sources)

    if args.require_map and not map_sources:
        _fatal("no map folders discovered under media/maps for enabled workshop items")

    map_names_ordered = order_maps(
        map_sources,
        base_map=str(args.base_map),
        workshop_ids_in_order=workshop_ids,
    )

    map_csv = ";".join(map_names_ordered)
    rewrite_ini_map_key(ini_path, map_csv=map_csv)

    if args.spawnregions_out is not None:
        generate_spawnregions_lua(
            out_path=Path(args.spawnregions_out),
            map_names_ordered=map_names_ordered,
        )
        print(f"Wrote spawnregions: {args.spawnregions_out}")

    print(
        f"Updated {ini_path}: Map=({len(map_names_ordered)} names,"
        f" {len(map_sources)} discovered map folders across {len(workshop_ids)} workshop items)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
