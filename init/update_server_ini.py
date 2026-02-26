#!/usr/bin/env python3
"""
Postinstall step: Update a Project Zomboid server INI (server.ini) with:
- Mods=
- WorkshopItems=
- Map=

Values are derived from the mods registry JSON.

Design goals
------------
- Idempotent: can be run repeatedly.
- Minimal mutation: only rewrites selected keys, leaves everything else intact.
- Works with multi-line INI continuation values (PZ sometimes wraps long lists).
- Prefers resolved/topologically ordered mod IDs from the plan, if present.

Expected registry shape
-----------------------
This script is tolerant to schema drift. It looks for:

Workshop IDs (strings numeric):
- plan["mods"]["enabledWorkshopIds"] (preferred)
- plan["mods"]["workshopIds"]
- plan["workshop"]["enabledWorkshopIds"]

Mod IDs (strings, may contain spaces):
- plan["mods"]["enabledModIdsOrdered"] (preferred)
- plan["mods"]["orderedModIds"]
- plan["mods"]["enabledModIds"]
- plan["mods"]["modIds"]

Map entries (map folder names, order matters in PZ):
- plan["maps"]["mapNamesOrdered"] (preferred)
- plan["maps"]["mapNames"]
- plan["mods"]["mapNamesOrdered"]
- plan["mods"]["mapNames"]
- plan["map"]["names"]

If your registry uses different field names, extend `extract_*` below.

Usage
-----
python3 update_server_ini.py --registry /path/to/mods.json --ini /path/to/server.ini

Exit codes
----------
0 success
2 invalid inputs
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence


def _fatal(msg: str) -> "None":
    print(f"ERROR: {msg}", file=sys.stderr)
    raise SystemExit(2)


def _load_json(path: Path) -> Dict[str, Any]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        _fatal(f"registry file not found: {path}")
        raise  # for type-checkers; unreachable
    except json.JSONDecodeError as e:
        _fatal(f"invalid JSON in registry {path}: {e}")
        raise  # for type-checkers; unreachable


def _unique_preserve_order(items: Iterable[Any]) -> List[str]:
    seen = set()
    out: List[str] = []
    for x in items:
        s = str(x).strip()
        if not s or s in seen:
            continue
        seen.add(s)
        out.append(s)
    return out


def _get_nested(plan: Dict[str, Any], path: Sequence[str]) -> Optional[Any]:
    cur: Any = plan
    for p in path:
        if not isinstance(cur, dict):
            return None
        if p not in cur:
            return None
        cur = cur[p]
    return cur


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


def extract_ordered_mod_ids(plan: Dict[str, Any]) -> List[str]:
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


def extract_ordered_map_names(plan: Dict[str, Any]) -> List[str]:
    """
    Extract ordered map names (PZ map folder names) from the registry.

    This does NOT scan the filesystem. It expects the registry to already
    include ordered map names, typically derived during mod planning/resolution.
    """
    candidates = [
        ("maps", "mapNamesOrdered"),
        ("maps", "mapNames"),
        ("mods", "mapNamesOrdered"),
        ("mods", "mapNames"),
        ("map", "names"),
    ]
    for c in candidates:
        v = _get_nested(plan, c)
        if isinstance(v, list) and v:
            names = [str(x).strip() for x in v if str(x).strip()]
            return _unique_preserve_order(names)
        if isinstance(v, str) and v.strip():
            raw = v.strip()
            parts = re.split(r"[;,]", raw)
            names = [p.strip() for p in parts if p.strip()]
            if names:
                return _unique_preserve_order(names)
    return []


def _is_continuation_line(s: str) -> bool:
    """
    A continuation line does not look like a new INI key, or blank/comment.
    """
    s = s.rstrip("\r\n")
    return (
        bool(s)
        and not s.startswith("#")
        and not re.match(r"[A-Za-z][A-Za-z0-9_]*\s*=", s)
    )


def rewrite_ini_keys(
    ini_path: Path,
    *,
    mods_csv: str,
    workshop_csv: str,
    map_csv: Optional[str],
) -> None:
    """
    Rewrite the Mods=, WorkshopItems=, and Map= entries in ini_path, preserving
    everything else. Handles multi-line INI values by skipping continuation
    lines for the keys being rewritten.
    """
    original = ini_path.read_text(encoding="utf-8", errors="replace")
    # Strip NUL bytes occasionally present in PZ saves
    if "\x00" in original:
        original = original.replace("\x00", "")

    out_lines: List[str] = []
    wrote_mods = False
    wrote_workshop = False
    wrote_map = False

    skipping = False
    for raw in original.splitlines(keepends=True):
        stripped = raw.rstrip("\r\n")

        if skipping:
            if _is_continuation_line(stripped):
                continue
            skipping = False

        if re.match(r"(?i)^Mods\s*=", stripped):
            out_lines.append(f"Mods={mods_csv}\n")
            wrote_mods = True
            skipping = True
            continue

        if re.match(r"(?i)^WorkshopItems\s*=", stripped):
            out_lines.append(f"WorkshopItems={workshop_csv}\n")
            wrote_workshop = True
            skipping = True
            continue

        if map_csv is not None and re.match(r"(?i)^Map\s*=", stripped):
            out_lines.append(f"Map={map_csv}\n")
            wrote_map = True
            skipping = True
            continue

        out_lines.append(raw)

    # Append missing keys
    if not wrote_mods:
        out_lines.append(f"Mods={mods_csv}\n")
    if not wrote_workshop:
        out_lines.append(f"WorkshopItems={workshop_csv}\n")
    if map_csv is not None and not wrote_map:
        out_lines.append(f"Map={map_csv}\n")

    ini_path.write_text("".join(out_lines), encoding="utf-8")


def mod_ids_to_pz_mods_csv(mod_ids: Sequence[str]) -> str:
    """
    PZ expects Mods= entries prefixed with a backslash: \\modA;\\modB;...
    Mod IDs may contain spaces; we keep them as-is.
    """
    # Avoid double-prefixing if the list already includes leading backslashes.
    norm = []
    for m in mod_ids:
        s = str(m).strip()
        if not s:
            continue
        while s.startswith("\\"):
            s = s[1:]
        norm.append(s)
    return ";".join(f"\\{m}" for m in norm)


def main(argv: Optional[Sequence[str]] = None) -> int:
    ap = argparse.ArgumentParser(
        description="Postinstall: update server.ini Mods=, WorkshopItems=, and Map= from mods registry."
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
        "--require-mod-ids",
        action="store_true",
        help="Fail if no mod IDs could be extracted from the registry.",
    )
    ap.add_argument(
        "--require-workshop-ids",
        action="store_true",
        help="Fail if no workshop IDs could be extracted from the registry.",
    )
    ap.add_argument(
        "--require-map-names",
        action="store_true",
        help="Fail if no map names could be extracted from the registry.",
    )
    ap.add_argument(
        "--no-map",
        action="store_true",
        help="Do not write Map= at all (leave existing ini Map= unchanged).",
    )
    args = ap.parse_args(list(argv) if argv is not None else None)

    plan_path: Path = args.registry
    ini_path: Path = args.ini

    if not plan_path.exists():
        _fatal(f"registry file not found: {plan_path}")
    if not ini_path.exists():
        _fatal(f"ini not found: {ini_path}")

    plan = _load_json(plan_path)

    workshop_ids = extract_enabled_workshop_ids(plan)
    mod_ids = extract_ordered_mod_ids(plan)
    map_names = extract_ordered_map_names(plan)

    if args.require_workshop_ids and not workshop_ids:
        _fatal("no workshop IDs found in registry")
    if args.require_mod_ids and not mod_ids:
        _fatal("no mod IDs found in registry")
    if args.require_map_names and not map_names:
        _fatal("no map names found in registry")

    workshop_csv = ";".join(workshop_ids)
    mods_csv = mod_ids_to_pz_mods_csv(mod_ids)
    map_csv = None if args.no_map else ";".join(map_names) if map_names else ""

    rewrite_ini_keys(
        ini_path,
        mods_csv=mods_csv,
        workshop_csv=workshop_csv,
        map_csv=map_csv,
    )

    wrote_map = not args.no_map
    map_count = len(map_names) if wrote_map else 0

    print(
        f"Updated {ini_path}: WorkshopItems=({len(workshop_ids)} ids), Mods=({len(mod_ids)} ids), Map=({map_count} names)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
