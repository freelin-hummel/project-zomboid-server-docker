#!/usr/bin/env python3
"""
Init Step: Cleanup / Verify Workshop Cache

Prunes stale workshop cache entries based on enabled workshop IDs in `mods.json`.
Writes cleanup bookkeeping under `resolution.cleanup`.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Set, Tuple


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


def unique_preserve_order(items: Iterable[Any]) -> List[str]:
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


def as_bool_env(name: str, default: bool) -> bool:
    v = os.environ.get(name, "")
    if not v.strip():
        return default
    return v.strip().lower() in ("1", "true", "yes", "y", "on")


def list_item_dirs(content_root: Path) -> List[Path]:
    if not content_root.is_dir():
        return []
    out: List[Path] = []
    for p in content_root.iterdir():
        try:
            if p.is_dir() or p.is_symlink():
                out.append(p)
        except OSError:
            out.append(p)
    return out


def prune_workshop_dirs(
    *,
    content_root: Path,
    keep_ids: Set[str],
    dry_run: bool,
) -> Tuple[List[str], List[str]]:
    pruned: List[str] = []
    kept: List[str] = []

    for item_path in sorted(list_item_dirs(content_root), key=lambda p: p.name):
        item_id = item_path.name
        if item_id in keep_ids:
            kept.append(item_id)
            continue

        if not (item_path.is_dir() or item_path.is_symlink()):
            continue

        pruned.append(item_id)
        if dry_run:
            log(f"dry-run: would prune stale workshop item dir: {item_path}")
            continue

        log(f"prune: removing stale workshop item dir: {item_path}")
        try:
            if item_path.is_symlink() or item_path.is_file():
                item_path.unlink(missing_ok=True)
            else:
                shutil.rmtree(item_path)
        except TypeError:
            try:
                if item_path.is_symlink() or item_path.is_file():
                    item_path.unlink()
                else:
                    shutil.rmtree(item_path)
            except FileNotFoundError:
                pass
        except Exception as ex:
            warn(f"failed to prune {item_path}: {ex}")

    return pruned, kept


def verify_workshop_dirs(content_root: Path, desired_ids: Sequence[str]) -> List[str]:
    return [wid for wid in desired_ids if not (content_root / wid).is_dir()]


def find_manifest_path(workshop_appid: str) -> Optional[Path]:
    steamappdir_s = os.environ.get("STEAMAPPDIR", "").strip()
    if not steamappdir_s:
        return None
    steamappdir = Path(steamappdir_s)
    return steamappdir / "steamapps" / "workshop" / f"appworkshop_{workshop_appid}.acf"


def prune_manifest_best_effort(
    *,
    manifest_path: Path,
    keep_ids: Sequence[str],
    helper_script: Optional[Path],
    dry_run: bool,
) -> bool:
    if dry_run:
        log(f"dry-run: would prune manifest: {manifest_path}")
        return False

    if not manifest_path.exists():
        warn(f"manifest not found: {manifest_path}")
        return False

    if helper_script is None or not helper_script.exists():
        warn("manifest prune helper script not found; skipping manifest pruning")
        return False

    import subprocess

    cmd = [sys.executable, str(helper_script), str(manifest_path), *list(keep_ids)]
    log(f"manifest: pruning with helper: {' '.join(cmd)}")
    proc = subprocess.run(cmd, check=False, stdout=sys.stdout, stderr=sys.stderr)
    return proc.returncode == 0


def main(argv: Sequence[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        description="Init step: prune and verify workshop cache based on mods registry."
    )
    ap.add_argument(
        "--registry",
        type=Path,
        default=Path(os.environ.get("MOD_CATALOG", "")).resolve()
        if os.environ.get("MOD_CATALOG", "").strip()
        else default_registry_path(),
        help="Path to mods.json (env: MOD_CATALOG).",
    )
    ap.add_argument(
        "--content-root",
        type=Path,
        default=None,
        help="Workshop content root (overrides registry.workshop.contentRoot).",
    )
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument(
        "--prune-cache",
        action="store_true",
        default=as_bool_env("PRUNE_WORKSHOP_CACHE", True),
    )
    ap.add_argument("--no-prune-cache", dest="prune_cache", action="store_false")
    ap.add_argument(
        "--prune-manifest",
        action="store_true",
        default=as_bool_env("PRUNE_WORKSHOP_MANIFEST", True),
    )
    ap.add_argument(
        "--no-prune-manifest", dest="prune_manifest", action="store_false"
    )
    ap.add_argument("--verify", action="store_true", default=True)
    ap.add_argument("--no-verify", dest="verify", action="store_false")
    ap.add_argument("--strict", action="store_true")
    ap.add_argument("--manifest-helper", type=Path, default=None)
    args = ap.parse_args(list(argv) if argv is not None else None)

    registry_path = args.registry
    if not registry_path.exists():
        err(f"mods registry does not exist: {registry_path}")
        return 2

    reg = load_json(registry_path)
    desired_ids = enabled_workshop_ids_from_registry(reg)
    keep_ids = set(desired_ids)

    workshop = reg.get("workshop", {}) if isinstance(reg.get("workshop"), dict) else {}
    workshop_appid = str(workshop.get("appId") or os.environ.get("WORKSHOP_APPID", "108600")).strip()

    content_root = args.content_root
    if content_root is None:
        root = workshop.get("contentRoot")
        content_root = Path(str(root)) if root else None

    reg.setdefault("resolution", {})
    cleanup = reg["resolution"].setdefault("cleanup", {})
    cleanup.setdefault("warnings", [])

    if content_root is None:
        msg = "No workshop content root available (neither --content-root nor registry.workshop.contentRoot)."
        if args.strict:
            err(msg)
            return 2
        warn(msg)
        cleanup["warnings"].append(msg)
        reg["generatedAt"] = utc_now_iso()
        save_json(registry_path, reg)
        return 0

    if not content_root.exists():
        msg = f"Workshop content root does not exist: {content_root}"
        if args.strict:
            err(msg)
            return 2
        warn(msg)
        cleanup["warnings"].append(msg)
        reg["generatedAt"] = utc_now_iso()
        save_json(registry_path, reg)
        return 0

    pruned_ids: List[str] = []
    kept_ids: List[str] = []
    if args.prune_cache:
        pruned_ids, kept_ids = prune_workshop_dirs(
            content_root=content_root, keep_ids=keep_ids, dry_run=args.dry_run
        )
    else:
        kept_ids = [p.name for p in list_item_dirs(content_root)]
        log("prune: cache pruning disabled")

    cleanup["prunedWorkshopItemIds"] = pruned_ids
    cleanup["keptWorkshopItemIds"] = sorted(list(set(kept_ids)))

    manifest_pruned = False
    if args.prune_manifest:
        manifest_path = find_manifest_path(workshop_appid)
        helper = args.manifest_helper
        if helper is None:
            candidates = [
                Path("/home/steam/prune_workshop_manifest.py"),
                Path("/data/zomboid/scripts/prune_workshop_manifest.py"),
            ]
            helper = next((p for p in candidates if p.exists()), None)

        if manifest_path is None:
            msg = "STEAMAPPDIR not set; cannot locate appworkshop manifest for pruning."
            if args.strict:
                err(msg)
                return 2
            warn(msg)
            cleanup["warnings"].append(msg)
        else:
            manifest_pruned = prune_manifest_best_effort(
                manifest_path=manifest_path,
                keep_ids=desired_ids,
                helper_script=helper,
                dry_run=args.dry_run,
            )

    cleanup["manifestPruned"] = manifest_pruned

    missing: List[str] = []
    if args.verify:
        missing = verify_workshop_dirs(content_root, desired_ids)
        cleanup["missingWorkshopItemIds"] = missing
        if missing:
            msg = f"verify: missing {len(missing)} enabled workshop item(s) on disk"
            err(msg + ": " + ", ".join(missing))

    reg["generatedAt"] = utc_now_iso()
    save_json(registry_path, reg)

    return 1 if missing else 0


if __name__ == "__main__":
    raise SystemExit(main())
