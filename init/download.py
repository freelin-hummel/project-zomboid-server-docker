#!/usr/bin/env python3
"""
Init Step: Download / Install Workshop Items (SteamCMD)

Reads the init registry (`mods.json`) and downloads enabled workshop items.
Writes install bookkeeping to a separate `*.last_run.json` file.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Sequence, Set


def log(msg: str) -> None:
    print(msg)


def warn(msg: str) -> None:
    print(f"WARNING: {msg}", file=sys.stderr)


def err(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def load_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, data: Dict[str, Any]) -> None:
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2, sort_keys=False)
        fh.write("\n")
    tmp.replace(path)


def default_registry_path() -> Path:
    return Path(__file__).resolve().parent / "mods.json"


def default_last_run_path(registry_path: Path) -> Path:
    base = registry_path.resolve()
    if base.suffix:
        return base.with_name(f"{base.stem}.last_run{base.suffix}")
    return base.with_name(base.name + ".last_run.json")


def normalize_last_run_state(raw: Dict[str, Any] | None = None) -> Dict[str, Any]:
    state: Dict[str, Any] = {}
    if isinstance(raw, dict):
        state.update(raw)
    state.setdefault("status", None)
    state.setdefault("message", None)
    state.setdefault("importedWorkshopIds", [])
    state.setdefault("importedModIds", [])
    state.setdefault("missingWorkshopIds", [])
    state.setdefault("missingModIds", [])
    state.setdefault("missingModIdsUnknownWorkshop", [])
    state.setdefault("cycles", [])
    state.setdefault("conflicts", [])
    state.setdefault("installPlannedWorkshopIds", [])
    state.setdefault("installCompletedWorkshopIds", [])
    state.setdefault("installFailedWorkshopIds", [])
    state.setdefault("enabledWorkshopIds", [])
    state.setdefault("enabledModIdsOrdered", [])
    return state


def load_last_run_state(path: Path) -> Dict[str, Any]:
    if path.exists():
        try:
            return normalize_last_run_state(load_json(path))
        except Exception as exc:
            warn(f"failed to load last-run file {path}: {exc}; using defaults")
    return normalize_last_run_state()


def save_last_run_state(path: Path, state: Dict[str, Any]) -> None:
    save_json(path, normalize_last_run_state(state))


def unique_preserve_order(items: Sequence[str]) -> List[str]:
    seen: Set[str] = set()
    out: List[str] = []
    for x in items:
        s = str(x).strip()
        if not s or s in seen:
            continue
        seen.add(s)
        out.append(s)
    return out


def enabled_workshop_ids_from_registry(reg: Dict[str, Any]) -> List[str]:
    mods_root = reg.get("mods")
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
        if wid and enabled_mod_ids:
            out.append(wid)
    return unique_preserve_order(out)


def is_downloaded(content_root: Path, wid: str) -> bool:
    return (content_root / str(wid)).is_dir()


def steamcmd_download(
    *,
    steamcmd_bin: str,
    steamappdir: Path,
    workshop_appid: str,
    steam_login: str,
    workshop_id: str,
    timeout_seconds: int,
) -> int:
    cmd = [
        steamcmd_bin,
        "+force_install_dir",
        str(steamappdir),
        "+login",
        steam_login,
        "+workshop_download_item",
        str(workshop_appid),
        str(workshop_id),
        "validate",
        "+quit",
    ]
    log(f"steamcmd: downloading workshop item {workshop_id} (app {workshop_appid})")
    try:
        proc = subprocess.run(
            cmd,
            stdout=sys.stdout,
            stderr=sys.stderr,
            check=False,
            timeout=timeout_seconds,
        )
        return int(proc.returncode)
    except subprocess.TimeoutExpired:
        warn(f"steamcmd: timed out downloading {workshop_id} after {timeout_seconds}s")
        return 124
    except FileNotFoundError:
        err(f"steamcmd binary not found: {steamcmd_bin}")
        return 127


def main(argv: Sequence[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        description="Init step: download workshop content from mods registry via steamcmd."
    )
    ap.add_argument(
        "--registry",
        type=Path,
        default=Path(os.environ.get("MOD_CATALOG", "")).resolve()
        if os.environ.get("MOD_CATALOG", "").strip()
        else default_registry_path(),
        help="Path to mods.json (env: MOD_CATALOG).",
    )
    ap.add_argument("--dry-run", action="store_true", help="Do not run steamcmd.")
    ap.add_argument(
        "--timeout-seconds",
        type=int,
        default=int(os.environ.get("STEAMCMD_TIMEOUT_SECONDS", "1800")),
        help="Per-item steamcmd timeout seconds.",
    )
    ap.add_argument(
        "--last-run-file",
        type=Path,
        default=Path(os.environ.get("LAST_RUN_FILE", "")).resolve()
        if os.environ.get("LAST_RUN_FILE", "").strip()
        else None,
        help="Path to write last-run metadata (env: LAST_RUN_FILE). Default: <registry>.last_run.json",
    )
    args = ap.parse_args(list(argv) if argv is not None else None)

    registry_path = args.registry
    if not registry_path.exists():
        err(f"mods registry does not exist: {registry_path}")
        return 2

    steamappdir_s = os.environ.get("STEAMAPPDIR", "").strip()
    if not steamappdir_s:
        err("STEAMAPPDIR is required for downloads")
        return 2
    steamappdir = Path(steamappdir_s)

    steamcmd_bin = os.environ.get("STEAMCMD_BIN", "steamcmd").strip() or "steamcmd"
    workshop_appid = os.environ.get("WORKSHOP_APPID", "108600").strip() or "108600"
    steam_login = os.environ.get("STEAM_LOGIN", "anonymous").strip() or "anonymous"

    if args.last_run_file is None:
        args.last_run_file = default_last_run_path(registry_path)

    reg = load_json(registry_path)
    lr = load_last_run_state(args.last_run_file)
    to_install = enabled_workshop_ids_from_registry(reg)

    lr["installPlannedWorkshopIds"] = list(to_install)

    workshop = reg.setdefault("workshop", {})
    content_root = workshop.get("contentRoot")
    content_root_path = Path(content_root) if content_root else None

    if not to_install:
        log("install: no enabled workshop IDs to install")
        lr["installCompletedWorkshopIds"] = []
        lr["installFailedWorkshopIds"] = []
        reg["generatedAt"] = utc_now_iso()
        save_json(registry_path, reg)
        save_last_run_state(args.last_run_file, lr)
        return 0

    if args.dry_run:
        log("dry-run: would install workshop IDs:")
        for wid in to_install:
            log(f"  - {wid}")
        return 0

    installed: List[str] = []
    failed: List[str] = []

    for wid in to_install:
        if content_root_path is not None and is_downloaded(content_root_path, wid):
            log(f"install: already present on disk: {wid}")
            installed.append(wid)
            continue

        rc = steamcmd_download(
            steamcmd_bin=steamcmd_bin,
            steamappdir=steamappdir,
            workshop_appid=workshop_appid,
            steam_login=steam_login,
            workshop_id=wid,
            timeout_seconds=int(args.timeout_seconds),
        )
        if rc == 0:
            installed.append(wid)
        else:
            failed.append(wid)

    lr["installCompletedWorkshopIds"] = installed
    lr["installFailedWorkshopIds"] = failed
    reg["generatedAt"] = utc_now_iso()
    save_json(registry_path, reg)
    save_last_run_state(args.last_run_file, lr)

    if failed:
        err("install: one or more workshop downloads failed: " + ", ".join(failed))
        return 1

    log(f"install: completed workshop downloads: {len(installed)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
