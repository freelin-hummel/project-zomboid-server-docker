#!/usr/bin/env python3
"""
Test: resolver ↔ INI sync (sanity check)

This script:
  1) Creates a temporary working directory
        3) Copies `zomboid/init/mods.json` into that temp dir
    2) Copies `zomboid/import-mods.yml` into that temp dir
        4) Runs `zomboid/init/resolver.lua` against the temp import-mods.yml catalog
     - SteamCMD installs are OPTIONAL and only run when configured via env vars
  5) Parses Mods= and WorkshopItems= from INI files in `zomboid/data/Server/*.ini`
  6) Validates that each INI is "covered by" the registry.

Default target:
  - By default, this test only checks `project-mortloid.ini` (to avoid failing on
    other profiles that may legitimately use different mod sets).
  - Override with `PZ_TEST_INI_FILTER` if you want to test multiple INIs.

Validation rule (default):
  - Each INI may represent a different server profile / mod set.
  - Therefore, we assert:
      INI.Mods         ⊆ registry.enabledMods
      INI.WorkshopItems ⊆ registry.enabledWorkshopItems
    i.e., an INI must not reference mods/workshop items that are unknown to the registry.
    (It is OK for the registry to contain more enabled mods than any particular INI.)

Optional stricter mode:
  - If you set `PZ_TEST_EXPECT_EXACT=true`, the test compares equality instead of subset.

SteamCMD install behavior (optional):
    - Installation is handled by pipeline download step, not resolver.

Why compare against registry instead of import-mods.yml?
    - By design, `import-mods.yml` is an import-only feed and may be cleaned/emptied.
  - The registry becomes the canonical source of truth.

Exit codes:
  0: all checked INIs satisfy the rule against registry
  1: mismatch found

Usage:
  python3 zomboid/tests/test_modinit_ini_sync.py

Optional:
  PZ_TEST_INI_FILTER="default.ini,project-mortloid.ini" python3 zomboid/tests/test_modinit_ini_sync.py
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Set, Tuple

RE_KEYVAL = re.compile(r"^\s*([A-Za-z][A-Za-z0-9_]*)\s*=\s*(.*)\s*$")


@dataclass(frozen=True)
class IniMods:
    mods: List[str]
    workshop_items: List[str]


def repo_root() -> Path:
    """
    Resolve repository root by walking up until we find `zomboid/`.
    This script is expected to live at `zomboid/tests/test_modinit_ini_sync.py`.
    """
    here = Path(__file__).resolve()
    for p in [here.parent, *here.parents]:
        if (p / "zomboid").is_dir():
            return p
    # Fallback: assume current working directory is repo root
    return Path.cwd().resolve()


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def split_csv(value: str) -> List[str]:
    """
    Split a semicolon-separated list with:
      - leading backslashes in Mods=
      - arbitrary whitespace
      - empty entries ignored
    """
    items: List[str] = []
    for part in (value or "").split(";"):
        part = part.strip()
        if not part:
            continue
        if part.startswith("\\"):
            part = part[1:]
        items.append(part)
    return items


def parse_ini_mods(path: Path) -> IniMods:
    """
    Parse Mods= and WorkshopItems= keys from an INI file.
    Keeps order as written.
    """
    mods: Optional[List[str]] = None
    workshop: Optional[List[str]] = None

    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        m = RE_KEYVAL.match(raw)
        if not m:
            continue
        key, val = m.group(1), m.group(2)
        if key == "Mods":
            mods = split_csv(val)
        elif key == "WorkshopItems":
            workshop = split_csv(val)

    return IniMods(mods=mods or [], workshop_items=workshop or [])


def registry_by_workshop_id(reg: dict) -> Dict[str, dict]:
    mods = reg.get("mods")
    if isinstance(mods, dict):
        return (mods.get("byWorkshopId") or {})

    by_wid: Dict[str, dict] = {}
    if isinstance(mods, list):
        for entry in mods:
            if not isinstance(entry, dict):
                continue
            wid = str(entry.get("workshopId", "")).strip()
            if not wid:
                continue

            mod_ids: List[str] = []
            for mod_entry in (entry.get("mods") or []):
                if not isinstance(mod_entry, dict):
                    continue
                if not bool(mod_entry.get("enabled", True)):
                    continue
                mid = str(mod_entry.get("id", "")).strip()
                if mid and mid not in mod_ids:
                    mod_ids.append(mid)

            by_wid[wid] = {
                "enabled": bool(entry.get("enabled", True)),
                "modIds": mod_ids,
            }

    return by_wid


def registry_enabled_workshop_ids(reg: dict) -> List[str]:
    by_wid = registry_by_workshop_id(reg)
    out: List[str] = []
    for wid, wentry in by_wid.items():
        enabled = bool((wentry or {}).get("enabled", True))
        if enabled:
            out.append(str(wid))
    # stable numeric sort
    return sorted(out, key=lambda s: int(s) if s.isdigit() else s)


def registry_enabled_mod_ids(reg: dict) -> List[str]:
    """
    Derive enabled mod IDs from the consolidated `mods.enabled` list.
    Order: numeric-sort workshop ID, then keep declared modIds order.
    """
    mods = reg.get("mods")
    if isinstance(mods, dict):
        enabled_set = {
            str(m).strip()
            for m in (mods.get("enabled") or [])
            if str(m).strip()
        }
    else:
        enabled_set = set()

    by_wid = registry_by_workshop_id(reg)
    enabled_wids = sorted(
        by_wid.keys(), key=lambda s: int(s) if str(s).isdigit() else str(s)
    )

    out: List[str] = []
    for wid in enabled_wids:
        wentry = by_wid.get(wid) or {}
        if not bool(wentry.get("enabled", True)):
            continue
        for mid in wentry.get("modIds") or []:
            if mid and (not enabled_set or mid in enabled_set) and mid not in out:
                out.append(str(mid))

    # Keep explicitly enabled IDs even if discovery metadata is missing.
    for mid in sorted(enabled_set):
        if mid not in out:
            out.append(mid)
    return out


def collect_ini_files(server_dir: Path) -> List[Path]:
    if not server_dir.is_dir():
        return []
    inis = sorted(server_dir.glob("*.ini"))
    filt = os.environ.get("PZ_TEST_INI_FILTER", "").strip()

    # Default: only validate the primary profile for now
    if not filt:
        filt = "project-mortloid.ini"

    allow = {s.strip() for s in filt.split(",") if s.strip()}
    return [p for p in inis if p.name in allow]


def assert_lists_equal(
    label: str, expected: Sequence[str], actual: Sequence[str], *, strict_order: bool
) -> Optional[str]:
    """
    Returns an error message if mismatch; otherwise None.
    """
    if strict_order:
        if list(expected) != list(actual):
            return (
                f"{label} order mismatch\n"
                f"  expected ({len(expected)}): {expected}\n"
                f"  actual   ({len(actual)}): {actual}\n"
            )
        return None

    exp_set, act_set = set(expected), set(actual)
    if exp_set != act_set:
        missing = sorted(exp_set - act_set)
        extra = sorted(act_set - exp_set)
        return (
            f"{label} set mismatch\n"
            f"  missing ({len(missing)}): {missing}\n"
            f"  extra   ({len(extra)}): {extra}\n"
        )
    return None


def assert_subset(
    label: str, universe: Sequence[str], subset: Sequence[str]
) -> Optional[str]:
    """
    Returns an error message if `subset` is not a subset of `universe`; otherwise None.
    Order is ignored (set semantics).

    This is the default comparison mode because multiple INI files may represent
    different server profiles with different mod sets, while the registry is the
    canonical superset of "known/allowed" mods.
    """
    uni_set, sub_set = set(universe), set(subset)
    if not sub_set.issubset(uni_set):
        extra = sorted(sub_set - uni_set)
        return (
            f"{label} contains entries not present in registry\n"
            f"  unknown/extra ({len(extra)}): {extra}\n"
        )
    return None


def run_modinit(
    *,
    resolver_lua: Path,
    lua_bin: str,
    registry_path: Path,
    mods_yml_path: Path,
    workshop_root: Optional[Path] = None,
) -> None:
    cmd = [
        lua_bin,
        str(resolver_lua),
        "--registry",
        str(registry_path),
        "--mods-yml",
        str(mods_yml_path),
        "--write",
    ]
    if workshop_root is not None:
        cmd += ["--workshop-root", str(workshop_root)]

    subprocess.run(cmd, check=True)


def main() -> int:
    root = repo_root()
    zomboid_dir = root / "zomboid"

    resolver_lua = zomboid_dir / "init" / "resolver.lua"
    lua_bin = os.environ.get("PZ_TEST_LUA_BIN", "lua5.4")
    registry_src = zomboid_dir / "init" / "mods.json"
    mods_yml_src = zomboid_dir / "import-mods.yml"
    server_dir = zomboid_dir / "data" / "Server"

    if not resolver_lua.is_file():
        print(f"ERROR: missing resolver runner: {resolver_lua}", file=sys.stderr)
        return 2
    if not registry_src.is_file():
        print(f"ERROR: missing registry: {registry_src}", file=sys.stderr)
        return 2
    if not mods_yml_src.is_file():
        print(f"ERROR: missing import-mods.yml: {mods_yml_src}", file=sys.stderr)
        return 2
    if not server_dir.is_dir():
        print(f"ERROR: missing server dir: {server_dir}", file=sys.stderr)
        return 2

    ini_files = collect_ini_files(server_dir)
    if not ini_files:
        print(f"ERROR: no INI files found under: {server_dir}", file=sys.stderr)
        return 2

    # Create an isolated temp workspace so test doesn't mutate working tree files.
    with tempfile.TemporaryDirectory(prefix="pz-init-test-") as td:
        tdir = Path(td)
        mods_yml_tmp = tdir / "import-mods.yml"
        registry_tmp = tdir / "registry.json"

        shutil.copy2(mods_yml_src, mods_yml_tmp)
        shutil.copy2(registry_src, registry_tmp)

        # Workshop root is optional for this test; if not present, resolver still imports.
        # You can point at a real workshop cache via PZ_TEST_WORKSHOP_ROOT.
        ws_root_env = os.environ.get("PZ_TEST_WORKSHOP_ROOT", "").strip()
        ws_root = Path(ws_root_env) if ws_root_env else None
        if ws_root is not None and not ws_root.exists():
            print(
                f"WARNING: PZ_TEST_WORKSHOP_ROOT set but does not exist: {ws_root}",
                file=sys.stderr,
            )
            ws_root = None

        run_modinit(
            resolver_lua=resolver_lua,
            lua_bin=lua_bin,
            registry_path=registry_tmp,
            mods_yml_path=mods_yml_tmp,
            workshop_root=ws_root,
        )

        reg = load_json(registry_tmp)
        expected_mods = registry_enabled_mod_ids(reg)
        expected_workshop = registry_enabled_workshop_ids(reg)

        # Compare against each INI
        strict = os.environ.get("PZ_TEST_STRICT_ORDER", "false").lower() == "true"
        expect_exact = os.environ.get("PZ_TEST_EXPECT_EXACT", "false").lower() == "true"
        failures: List[str] = []

        for ini in ini_files:
            parsed = parse_ini_mods(ini)

            if expect_exact:
                # Exact match mode (legacy behavior)
                e1 = assert_lists_equal(
                    f"{ini.name}: Mods", expected_mods, parsed.mods, strict_order=strict
                )
                if e1:
                    failures.append(e1)

                e2 = assert_lists_equal(
                    f"{ini.name}: WorkshopItems",
                    expected_workshop,
                    parsed.workshop_items,
                    strict_order=strict,
                )
                if e2:
                    failures.append(e2)
            else:
                # Default: each INI must be a subset of the registry superset
                e1 = assert_subset(f"{ini.name}: Mods", expected_mods, parsed.mods)
                if e1:
                    failures.append(e1)

                e2 = assert_subset(
                    f"{ini.name}: WorkshopItems",
                    expected_workshop,
                    parsed.workshop_items,
                )
                if e2:
                    failures.append(e2)

        if failures:
            print("FAIL: INI files are not in sync with registry", file=sys.stderr)
            for f in failures:
                print(f, file=sys.stderr)
            print(
                "Hints:\n"
                "  - If only ordering differs and you don't care, omit PZ_TEST_STRICT_ORDER=true.\n"
                "  - Ensure your entrypoint/process_mods writes Mods=/WorkshopItems= from the same source.\n",
                file=sys.stderr,
            )
            return 1

        print(
            f"PASS: {len(ini_files)} INI file(s) match registry "
            f"(mods={len(expected_mods)} workshopItems={len(expected_workshop)})"
        )
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
