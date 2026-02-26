#!/bin/bash
set -euo pipefail

HOMEDIR="${HOMEDIR:-/home/steam}"
STEAMCMD_BIN="${STEAMCMD_BIN:-steamcmd}"
STEAMAPPID="${STEAMAPPID:-380870}"
WORKSHOP_APPID="${WORKSHOP_APPID:-108600}"
PRUNE_WORKSHOP_CACHE="${PRUNE_WORKSHOP_CACHE:-true}"
# Pruning is handled by the init cleanup step now. Keep this for backwards
# compatibility, but do not prune from the entrypoint to avoid duplicate work.
# Set to "true" to skip the steamcmd validate pass on game files at startup.
# Saves ~30-60s on restarts when you know game files are intact.
SKIP_VALIDATE="${SKIP_VALIDATE:-false}"
STEAMAPP="${STEAMAPP:-project-zomboid}"
STEAMAPPDIR="${STEAMAPPDIR:-${HOMEDIR}/${STEAMAPP}-dedicated}"
STEAMAPPBRANCH="${STEAMAPPBRANCH:-public}"
IMPORT_MODS_YML="${IMPORT_MODS_YML:-${MODS_YML:-${HOMEDIR}/import-mods.yml}}"
if [[ ! -f "${IMPORT_MODS_YML}" && -f "${HOMEDIR}/mods.yml" ]]; then
  IMPORT_MODS_YML="${HOMEDIR}/mods.yml"
fi
ZOMBOID_CACHEDIR="${ZOMBOID_CACHEDIR:-${HOMEDIR}/Zomboid}"
# PZ expects a semicolon-separated list for -modfolders (not commas).
MOD_FOLDERS="${MOD_FOLDERS:-workshop;steam;mods}"
SERVER_NAME="${SERVER_NAME}"
# Use a single fixed server profile name so PZ reads:
#   ${HOMEDIR}/Zomboid/Server/server.ini
# consistently across all environments.
SERVER_PROFILE="server"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-mort}"
CONFIG_XMX="${CONFIG_XMX:-10}"
CONFIG_PATH="${STEAMAPPDIR}/ProjectZomboid64.json"
RCON_PORT="${RCON_PORT:-27015}"
RCON_PASSWORD="${RCON_PASSWORD:-}"

export LD_LIBRARY_PATH="${STEAMAPPDIR}/jre64:${LD_LIBRARY_PATH:-}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"
if [[ -n "${JAVA_TOOL_OPTIONS:-}" ]]; then
  export JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS} -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"
else
  export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"
fi

INIT_PIPELINE="${INIT_PIPELINE:-true}"

echo "Installing/updating app ${STEAMAPPID} into ${STEAMAPPDIR}"

mkdir -p "${STEAMAPPDIR}"

parse_workshop_ids_from_import_mods_yml() {
  # Parse Workshop ID: lines from import-mods.yml feed format:
  #   Workshop ID: <number>    <- implicit block start
  #   Mod ID: <name>
  #   ---                      <- explicit block end
  # To remove a workshop item, simply delete its block from import-mods.yml.
  WORKSHOP_IDS=()
  [[ -f "${IMPORT_MODS_YML}" ]] || return
  local wid
  while IFS= read -r wid; do
    [[ -n "${wid}" ]] && WORKSHOP_IDS+=("${wid}")
  done < <(python3 - "${IMPORT_MODS_YML}" <<'PYEOF'
import re, sys
from pathlib import Path

path = Path(sys.argv[1])
seen, current_wid = set(), None
for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
    line = raw.strip()
    if line == "---":
        if current_wid and current_wid not in seen:
            print(current_wid)
            seen.add(current_wid)
        current_wid = None
        continue
    m = re.match(r"(?i)^workshop\s+id\s*:\s*(\S+)", line)
    if m:
        # flush previous block if no --- was found (legacy format)
        if current_wid and current_wid not in seen:
            print(current_wid)
            seen.add(current_wid)
        current_wid = m.group(1)
# flush last block if file ends without ---
if current_wid and current_wid not in seen:
    print(current_wid)
PYEOF
)
}

find_workshop_content_root() {
  WORKSHOP_CONTENT_ROOT=""
  local candidate
  for candidate in \
    "${STEAMAPPDIR}/steamapps/workshop/content/${WORKSHOP_APPID}" \
    "${HOMEDIR}/.local/share/Steam/steamapps/workshop/content/${WORKSHOP_APPID}" \
    "${HOMEDIR}/.steam/steam/steamapps/workshop/content/${WORKSHOP_APPID}" \
    "${HOMEDIR}/Steam/steamapps/workshop/content/${WORKSHOP_APPID}"; do
    if [[ -d "${candidate}" ]]; then
      WORKSHOP_CONTENT_ROOT="${candidate}"
      return
    fi
  done
}
prune_workshop_cache() {
  # NOTE: This is intentionally a no-op now.
  #
  # Workshop cache pruning (and optional manifest pruning) is handled by the
  # init cleanup step that runs before the server container starts.
  #
  # Keeping the function (and PRUNE_WORKSHOP_CACHE env) avoids breaking older
  # scripts/configs that still set PRUNE_WORKSHOP_CACHE=true.
  return 0
}



install_app() {
  local validate_flag=""
  [[ "${SKIP_VALIDATE}" != "true" ]] && validate_flag="validate"

  if [[ "${STEAMAPPBRANCH}" == "public" || "${STEAMAPPBRANCH}" == "latest" || -z "${STEAMAPPBRANCH}" ]]; then
    "${STEAMCMD_BIN}" \
      +force_install_dir "${STEAMAPPDIR}" \
      +login anonymous \
      +app_update "${STEAMAPPID} ${validate_flag}" \
      +quit
  else
    "${STEAMCMD_BIN}" \
      +force_install_dir "${STEAMAPPDIR}" \
      +login anonymous \
      +app_update "${STEAMAPPID} -beta ${STEAMAPPBRANCH} ${validate_flag}" \
      +quit
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

install_app

if [[ "${INIT_PIPELINE}" == "true" ]]; then
  echo "Running consolidated init pipeline (/data/zomboid/init/pipeline.sh)"
  /bin/bash /data/zomboid/init/pipeline.sh
else
  echo "Skipping consolidated init pipeline (INIT_PIPELINE=${INIT_PIPELINE})"
fi

mkdir -p "${ZOMBOID_CACHEDIR}" "${ZOMBOID_CACHEDIR}/mods"

# Prevent PZ's embedded Steam client from queueing re-downloads of mods that
# are already on disk. If NeedsUpdate/NeedsDownload were set (e.g. after a
# directory restructure), the server will fail on startup trying to reach Steam.
_acf="${STEAMAPPDIR}/steamapps/workshop/appworkshop_${WORKSHOP_APPID}.acf"
if [[ -f "${_acf}" ]]; then
  sed -i \
    -e 's/"NeedsUpdate"\s*"[^"]*"/"NeedsUpdate"\t\t"0"/' \
    -e 's/"NeedsDownload"\s*"[^"]*"/"NeedsDownload"\t\t"0"/' \
    "${_acf}"
fi
unset _acf

# Pruning is performed by the consolidated init pipeline now.
# We still parse workshop IDs to keep behavior consistent if other logic
# later depends on WORKSHOP_IDS/WORKSHOP_CONTENT_ROOT.
parse_workshop_ids_from_import_mods_yml
if [[ ${#WORKSHOP_IDS[@]} -gt 0 ]]; then
  find_workshop_content_root
  prune_workshop_cache
fi

# Case-symlink fixes are applied by the consolidated init pipeline now.
#
# `process_mods.py` was previously responsible for:
#  - validating import-mods.yml blocks against downloaded workshop content
#  - enforcing topological order w.r.t. mod.info requires
#  - rewriting import-mods.yml blocks
#  - writing Mods=/WorkshopItems=/Map=/PublicName= into default.ini
#
# With the current init pipeline producing a resolved plan and updating server config
# earlier in this entrypoint, running legacy process_mods here would be duplicate work.

# RCON settings should be written by an init step (so the server container
# doesn't need Python). If you still want runtime overrides, implement them
# with sed/awk here instead.



if [[ -f "${CONFIG_PATH}" ]]; then
  sed -i "s=Xmx8g=Xmx${CONFIG_XMX}g=g" "${CONFIG_PATH}" || true
  sed -i "s=UseZGC=UseG1GC=g" "${CONFIG_PATH}" || true
fi

# Always start using the fixed profile name `server`, which maps to:
#   ${HOMEDIR}/Zomboid/Server/server.ini
exec "${STEAMAPPDIR}/start-server.sh" -cachedir="${ZOMBOID_CACHEDIR}" -modfolders="${MOD_FOLDERS}" -servername "server" -adminpassword "${ADMIN_PASSWORD}"
