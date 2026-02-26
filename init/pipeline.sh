#!/bin/bash
set -euo pipefail

# pipeline.sh — Project Zomboid initialization pipeline runner
#
# This script is intended to be executed inside the same container image as the
# dedicated server (e.g. steamcmd/steamcmd:latest) *before* starting PZ.
#
# It performs four steps:
#   1) RESOLVE : import mods feed into registry and resolve ordering
#   2) DL      : download workshop items from mods registry using steamcmd
#   3) CLEAN : prune stale workshop cache/manifest and verify required items exist
#   4) LUA-PROBE: final runtime probe pass (updates registry + writes reports)
#
# Required mounts/paths (typical):
#   /data/zomboid                -> your persisted config root
#   /home/steam/project-zomboid-dedicated  -> STEAMAPPDIR (steamcmd force_install_dir)
#
# Environment variables you likely already have:
#   STEAMAPPDIR        (required for download step)
#   WORKSHOP_APPID     (default: 108600)
#   STEAMCMD_BIN       (default: steamcmd)
#   STEAM_LOGIN        (default: anonymous)
#   STEAMCMD_TIMEOUT_SECONDS (default: 1800)
#
# Optional:
#   IMPORT_MODS_YML       (default: /data/zomboid/import-mods.yml)
#   MODS_YML              (compat alias)
#   MOD_CATALOG           (default: /data/zomboid/init/mods.json)
#   LAST_RUN_FILE         (default: /data/zomboid/init/mods.last_run.json)
#   WORKSHOP_CONTENT_ROOT  (default: derived from STEAMAPPDIR)
#   INIT_NO_DOWNLOAD       ("true" to skip download step)
#   INIT_NO_CLEANUP        ("true" to skip cleanup step)
#   INIT_NO_LUA_CHECK      ("true" to skip final Lua runtime probe)
#   LUA_BIN                (default: lua5.4)
#   LUA_REPORT_TXT         (default: /data/zomboid/init/stub-runtime-reorder-report.txt)
#   LUA_REPORT_JSON        (default: /data/zomboid/init/stub-runtime-report.json)
#   LUA_RETRY_FROM_JSON    (optional prior JSON report to seed order)
#   LUA_UMBRELLA_ROOT      (optional stubs root for runtime probe)
#   LUA_MAX_ITEMS          (optional max workshop items to probe)
#   LUA_MAX_FILES          (optional max lua files to probe)
#
# Typical usage from an entrypoint:
#   /bin/bash /data/zomboid/init/pipeline.sh

say() { echo "[init] $*"; }
warn() { echo "[init] WARNING: $*" >&2; }
die() { echo "[init] ERROR: $*" >&2; exit 1; }

# ----------------------------
# Defaults / paths
# ----------------------------

IMPORT_MODS_YML="${IMPORT_MODS_YML:-${MODS_YML:-/data/zomboid/import-mods.yml}}"
if [[ ! -f "${IMPORT_MODS_YML}" && -f "/data/zomboid/mods.yml" ]]; then
  warn "Using legacy mods.yml feed at /data/zomboid/mods.yml; migrate to /data/zomboid/import-mods.yml"
  IMPORT_MODS_YML="/data/zomboid/mods.yml"
fi
MOD_CATALOG="${MOD_CATALOG:-/data/zomboid/init/mods.json}"
LAST_RUN_FILE="${LAST_RUN_FILE:-/data/zomboid/init/mods.last_run.json}"

# steamcmd-related defaults
WORKSHOP_APPID="${WORKSHOP_APPID:-108600}"
STEAMCMD_BIN="${STEAMCMD_BIN:-steamcmd}"
STEAM_LOGIN="${STEAM_LOGIN:-anonymous}"
STEAMCMD_TIMEOUT_SECONDS="${STEAMCMD_TIMEOUT_SECONDS:-1800}"

# Required for downloads (steamcmd +force_install_dir)
STEAMAPPDIR="${STEAMAPPDIR:-}"

# workshop content root (where workshop item dirs live)
# Prefer explicit override; otherwise default to the path used by the server entrypoint.
WORKSHOP_CONTENT_ROOT="${WORKSHOP_CONTENT_ROOT:-}"
if [[ -z "${WORKSHOP_CONTENT_ROOT}" && -n "${STEAMAPPDIR}" ]]; then
  WORKSHOP_CONTENT_ROOT="${STEAMAPPDIR}/steamapps/workshop/content/${WORKSHOP_APPID}"
fi

# scripts (inside the repository-mounted tree)
RESOLVER_LUA="/data/zomboid/init/resolver.lua"
DL_PY="/data/zomboid/init/download.py"
CLEAN_PY="/data/zomboid/init/cleanup.py"

INIT_NO_DOWNLOAD="${INIT_NO_DOWNLOAD:-false}"
INIT_NO_CLEANUP="${INIT_NO_CLEANUP:-false}"
INIT_NO_LUA_CHECK="${INIT_NO_LUA_CHECK:-false}"
LUA_BIN="${LUA_BIN:-lua5.4}"
LUA_REPORT_TXT="${LUA_REPORT_TXT:-/data/zomboid/init/stub-runtime-reorder-report.txt}"
LUA_REPORT_JSON="${LUA_REPORT_JSON:-/data/zomboid/init/stub-runtime-report.json}"
LUA_RETRY_FROM_JSON="${LUA_RETRY_FROM_JSON:-}"
LUA_UMBRELLA_ROOT="${LUA_UMBRELLA_ROOT:-}"
LUA_MAX_ITEMS="${LUA_MAX_ITEMS:-0}"
LUA_MAX_FILES="${LUA_MAX_FILES:-0}"

# ----------------------------
# Preconditions
# ----------------------------

[[ -f "${DL_PY}" ]] || die "Missing download step: ${DL_PY}"
[[ -f "${CLEAN_PY}" ]] || die "Missing cleanup step: ${CLEAN_PY}"
[[ -f "${MOD_CATALOG}" ]] || die "Missing catalog: ${MOD_CATALOG}"
[[ -f "${IMPORT_MODS_YML}" ]] || warn "import-mods.yml not found at ${IMPORT_MODS_YML} (import feed will be empty)"
[[ -f "${RESOLVER_LUA}" ]] || die "Missing lua resolver: ${RESOLVER_LUA}"
command -v "${LUA_BIN}" >/dev/null 2>&1 || die "Lua binary not found for resolver: ${LUA_BIN}"

if [[ -z "${STEAMAPPDIR}" ]]; then
  warn "STEAMAPPDIR is not set. Download step will fail if enabled."
fi

say "catalog      : ${MOD_CATALOG}"
say "last-run     : ${LAST_RUN_FILE}"
say "mods feed    : ${IMPORT_MODS_YML}"
say "workshop app : ${WORKSHOP_APPID}"
say "content root : ${WORKSHOP_CONTENT_ROOT:-<unset>}"
say "steamappdir  : ${STEAMAPPDIR:-<unset>}"
say "steam login  : ${STEAM_LOGIN}"
say "steamcmd bin : ${STEAMCMD_BIN}"
say "timeout (s)  : ${STEAMCMD_TIMEOUT_SECONDS}"
say "resolver impl: lua"
say "lua bin      : ${LUA_BIN}"
say "lua report   : ${LUA_REPORT_TXT}"
say "lua json     : ${LUA_REPORT_JSON}"

# ----------------------------
# Step 1: RESOLVE
# ----------------------------

say "STEP 1/4: resolve (import mods feed into registry + resolve ordering)"

# We pass --write to persist registry updates and to clean import-mods.yml (import-only).
# We DO NOT auto-install here; download is a dedicated step.
"${LUA_BIN}" "${RESOLVER_LUA}" \
  --registry "${MOD_CATALOG}" \
  --last-run-file "${LAST_RUN_FILE}" \
  --mods-yml "${IMPORT_MODS_YML}" \
  --workshop-root "${WORKSHOP_CONTENT_ROOT}" \
  --workshop-appid "${WORKSHOP_APPID}" \
  --write

# ----------------------------
# Step 2: DOWNLOAD
# ----------------------------

if [[ "${INIT_NO_DOWNLOAD}" == "true" ]]; then
  say "STEP 2/4: download skipped (INIT_NO_DOWNLOAD=true)"
else
  say "STEP 2/4: download (steamcmd workshop_download_item)"

  [[ -n "${STEAMAPPDIR}" ]] || die "STEAMAPPDIR is required for download step"

  export STEAMAPPDIR
  export WORKSHOP_APPID
  export STEAMCMD_BIN
  export STEAM_LOGIN
  export STEAMCMD_TIMEOUT_SECONDS
  python3 -u "${DL_PY}" --registry "${MOD_CATALOG}" --last-run-file "${LAST_RUN_FILE}"
fi

# ----------------------------
# Step 3: CLEANUP / VERIFY
# ----------------------------

if [[ "${INIT_NO_CLEANUP}" == "true" ]]; then
  say "STEP 3/4: cleanup skipped (INIT_NO_CLEANUP=true)"
else
  say "STEP 3/4: cleanup (prune + verify)"

  export STEAMAPPDIR
  export WORKSHOP_APPID
  # By default, cleanup.py prunes cache + manifest (best-effort) and verifies.
  python3 -u "${CLEAN_PY}" --registry "${MOD_CATALOG}"
fi

# ----------------------------
# Step 4: LUA PROBE (FINAL PASS)
# ----------------------------

if [[ "${INIT_NO_LUA_CHECK}" == "true" ]]; then
  say "STEP 4/4: lua-probe skipped (INIT_NO_LUA_CHECK=true)"
else
  say "STEP 4/4: final runtime pass (probe + dependency autofix + reports)"

  command -v "${LUA_BIN}" >/dev/null 2>&1 || die "Lua binary not found: ${LUA_BIN}"

  probe_args=(
    --registry "${MOD_CATALOG}"
    --last-run-file "${LAST_RUN_FILE}"
    --mods-yml "${IMPORT_MODS_YML}"
    --workshop-root "${WORKSHOP_CONTENT_ROOT}"
    --workshop-appid "${WORKSHOP_APPID}"
    --runtime-probe
    --probe-report-file "${LUA_REPORT_TXT}"
    --probe-json-report-file "${LUA_REPORT_JSON}"
    --probe-max-items "${LUA_MAX_ITEMS}"
    --probe-max-files "${LUA_MAX_FILES}"
    --write
  )
  if [[ -n "${LUA_UMBRELLA_ROOT}" ]]; then
    probe_args+=(--probe-umbrella-root "${LUA_UMBRELLA_ROOT}")
  fi
  if [[ -n "${LUA_RETRY_FROM_JSON}" ]]; then
    probe_args+=(--probe-retry-from-json "${LUA_RETRY_FROM_JSON}")
  fi

  "${LUA_BIN}" "${RESOLVER_LUA}" "${probe_args[@]}"
fi

say "init pipeline complete"
