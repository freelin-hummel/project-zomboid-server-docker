#!/bin/bash
set -euo pipefail

# mod_download.sh — SteamCMD-only workshop downloader
#
# Reads the mods registry JSON (mods.json) and downloads the
# enabled workshop items via steamcmd.
#
# This script intentionally avoids Python and should run in `steamcmd/steamcmd:latest`.
#
# Inputs:
#   - mods registry JSON at: ${MOD_CATALOG}
#
# Required env:
#   - STEAMAPPDIR: steamcmd +force_install_dir target
#
# Optional env:
#   - MOD_CATALOG: default /data/zomboid/init/mods.json
#   - WORKSHOP_APPID: default 108600
#   - STEAMCMD_BIN: default steamcmd
#   - STEAM_LOGIN: default anonymous
#   - STEAMCMD_TIMEOUT_SECONDS: per-item timeout, default 1800
#   - STEAMCMD_VALIDATE: "true" to add validate (default true)
#
# Exit codes:
#   0 success
#   1 one or more downloads failed
#   2 invalid configuration / missing inputs

say()  { echo "[mod-download] $*"; }
warn() { echo "[mod-download] WARNING: $*" >&2; }
die()  { echo "[mod-download] ERROR: $*" >&2; exit 2; }

MOD_CATALOG="${MOD_CATALOG:-/data/zomboid/init/mods.json}"
WORKSHOP_APPID="${WORKSHOP_APPID:-108600}"
STEAMCMD_BIN="${STEAMCMD_BIN:-steamcmd}"
STEAM_LOGIN="${STEAM_LOGIN:-anonymous}"
STEAMCMD_TIMEOUT_SECONDS="${STEAMCMD_TIMEOUT_SECONDS:-1800}"
STEAMCMD_VALIDATE="${STEAMCMD_VALIDATE:-true}"

STEAMAPPDIR="${STEAMAPPDIR:-}"
[[ -n "${STEAMAPPDIR}" ]] || die "STEAMAPPDIR is required (steamcmd +force_install_dir target)"
[[ -f "${MOD_CATALOG}" ]] || die "Registry not found: ${MOD_CATALOG}"

# workshop content root: <steamappdir>/steamapps/workshop/content/<appid>
WORKSHOP_CONTENT_ROOT="${STEAMAPPDIR}/steamapps/workshop/content/${WORKSHOP_APPID}"

say "registry      : ${MOD_CATALOG}"
say "steamcmd      : ${STEAMCMD_BIN}"
say "steam login   : ${STEAM_LOGIN}"
say "steamappdir   : ${STEAMAPPDIR}"
say "workshop app  : ${WORKSHOP_APPID}"
say "content root  : ${WORKSHOP_CONTENT_ROOT}"
say "timeout (s)   : ${STEAMCMD_TIMEOUT_SECONDS}"
say "validate      : ${STEAMCMD_VALIDATE}"

# Extract workshop IDs from mods.json without jq/python.
# We keep it intentionally simple and compatible with busybox/mawk:
# - Look for the `enabledWorkshopIds` array
# - Read until the closing ']'
# - Extract JSON string literals on those lines using gsub (mawk-safe)
#
# This assumes the plan uses JSON strings like: "1234567890"
extract_enabled_workshop_ids() {
  # Print one workshop ID per line.
  # After encountering "enabledWorkshopIds", read until ']' and extract quoted strings.
  awk '
    BEGIN { in_arr=0 }
    /"enabledWorkshopIds"[[:space:]]*:[[:space:]]*\[/ { in_arr=1; next }
    in_arr==1 {
      if ($0 ~ /\]/) { in_arr=0; exit }
      line=$0
      # Replace each "string" with a newline-delimited token (mawk-safe; avoids match(..., ..., array))
      gsub(/"[^"]+"/, "\n&\n", line)
      n = split(line, a, "\n")
      for (i=1; i<=n; i++) {
        tok = a[i]
        if (tok ~ /^"[^"]+"$/) {
          gsub(/^"/, "", tok)
          gsub(/"$/, "", tok)
          print tok
        }
      }
    }
  ' "${MOD_CATALOG}" \
    | sed -e 's/^[[:space:]]*//; s/[[:space:]]*$//' \
    | grep -E '^[0-9]+$' || true
}

WORKSHOP_IDS_RAW="$(extract_enabled_workshop_ids || true)"
if [[ -z "${WORKSHOP_IDS_RAW}" ]]; then
  warn "No enabledWorkshopIds found in registry; nothing to download."
  exit 0
fi

# De-dup while preserving order
WORKSHOP_IDS=()
declare -A _seen=()
while IFS= read -r wid; do
  [[ -n "${wid}" ]] || continue
  if [[ -z "${_seen[${wid}]+x}" ]]; then
    WORKSHOP_IDS+=("${wid}")
    _seen["${wid}"]=1
  fi
done <<< "${WORKSHOP_IDS_RAW}"

say "workshop IDs  : ${#WORKSHOP_IDS[@]}"

mkdir -p "${WORKSHOP_CONTENT_ROOT}"

download_one() {
  local wid="$1"
  if [[ -d "${WORKSHOP_CONTENT_ROOT}/${wid}" ]]; then
    say "already present: ${wid}"
    return 0
  fi

  local validate_arg=()
  if [[ "${STEAMCMD_VALIDATE}" == "true" ]]; then
    validate_arg=("validate")
  fi

  say "downloading: ${wid}"

  # Timeout wrapper (portable-ish): use `timeout` if present, else run without it.
  if command -v timeout >/dev/null 2>&1; then
    timeout "${STEAMCMD_TIMEOUT_SECONDS}" \
      "${STEAMCMD_BIN}" \
        +force_install_dir "${STEAMAPPDIR}" \
        +login "${STEAM_LOGIN}" \
        +workshop_download_item "${WORKSHOP_APPID}" "${wid}" "${validate_arg[@]}" \
        +quit
  else
    warn "timeout command not found; running steamcmd without a timeout"
    "${STEAMCMD_BIN}" \
      +force_install_dir "${STEAMAPPDIR}" \
      +login "${STEAM_LOGIN}" \
      +workshop_download_item "${WORKSHOP_APPID}" "${wid}" "${validate_arg[@]}" \
      +quit
  fi
}

failed=0
failed_ids=()

for wid in "${WORKSHOP_IDS[@]}"; do
  if download_one "${wid}"; then
    :
  else
    warn "download failed: ${wid}"
    failed=1
    failed_ids+=("${wid}")
  fi
done

if [[ "${failed}" -ne 0 ]]; then
  warn "failed workshop IDs: ${failed_ids[*]}"
  exit 1
fi

say "all downloads completed successfully"
exit 0
