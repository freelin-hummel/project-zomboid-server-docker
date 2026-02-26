#!/usr/bin/env python3
"""
fix_case_symlinks.py — Create lowercase symlinks for Windows-authored mods on Linux.

Project Zomboid resolves x_extends= and other cross-file references using the
lowercased path. Mods authored on Windows (case-insensitive FS) often have
mixed-case directory and file names that fail to resolve on Linux.

This script walks a directory tree and, for every entry whose name contains
uppercase letters, creates a lowercase symlink pointing to the real entry —
in the same parent directory. Existing correct symlinks are skipped.

Usage:
    python3 scripts/fix_case_symlinks.py <root_dir> [<root_dir> ...]

    # all active workshop mods:
    python3 scripts/fix_case_symlinks.py workshop-mods/content/108600/*

    # single mod:
    python3 scripts/fix_case_symlinks.py workshop-mods/content/108600/3403870858
"""
from __future__ import annotations

import os
import sys
from pathlib import Path


def fix_dir(root: Path, *, dry_run: bool = False) -> tuple[int, int]:
    """
    Walk *root* top-down and create lowercase symlinks where needed.

    Returns ``(created, skipped)`` counts.
    """
    created = 0
    skipped = 0

    # os.walk top-down so that when we symlink a directory its contents are
    # visited by subsequent iterations (the real dir, not the symlink).
    for dirpath, dirnames, filenames in os.walk(root, followlinks=False):
        parent = Path(dirpath)

        entries = [(n, True) for n in dirnames] + [(n, False) for n in filenames]
        for name, is_dir in entries:
            lower = name.lower()
            if lower == name:
                continue  # already lowercase, nothing needed

            link = parent / lower
            target = parent / name

            if link.exists() or link.is_symlink():
                # Check it already points to the right place
                if link.is_symlink() and os.readlink(link) == name:
                    skipped += 1
                    continue
                # Exists but wrong target — skip with a warning
                print(f"  SKIP (exists, wrong target): {link} -> {os.readlink(link) if link.is_symlink() else '(real file)'}")
                skipped += 1
                continue

            if dry_run:
                print(f"  would create: {link} -> {name}")
            else:
                # Symlink target is relative (just the name), so it works
                # regardless of where the tree is mounted.
                os.symlink(name, link)
                created += 1

    return created, skipped


def main() -> None:
    import argparse
    ap = argparse.ArgumentParser(description="Create lowercase symlinks for mixed-case mod files")
    ap.add_argument("roots", nargs="+", help="Root directories to process")
    ap.add_argument("--dry-run", action="store_true", help="Print what would be done without creating anything")
    args = ap.parse_args()

    total_created = total_skipped = 0
    for raw in args.roots:
        root = Path(raw)
        if not root.is_dir():
            print(f"SKIP (not a dir): {root}")
            continue
        print(f"Processing: {root}")
        c, s = fix_dir(root, dry_run=args.dry_run)
        print(f"  {'would create' if args.dry_run else 'created'} {c} symlink(s), {s} already OK")
        total_created += c
        total_skipped += s

    print(f"\nTotal: {total_created} created, {total_skipped} skipped")


if __name__ == "__main__":
    main()
