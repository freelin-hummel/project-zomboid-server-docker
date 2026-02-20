#!/bin/bash

set -u

LOG_FILE="${CASE_FIX_LOG_FILE:-${HOMEDIR:-$HOME}/Zomboid/server-console.txt}"
WORKSHOP_ROOT="${CASE_FIX_WORKSHOP_ROOT:-${STEAMAPPDIR:-$HOME/pz-dedicated}/steamapps/workshop/content/108600}"
MARKER="steamapps/workshop/content/108600/"

echo "*** INFO: Project Zomboid mod case fixer start ***"
echo "*** INFO: Log file: ${LOG_FILE} ***"
echo "*** INFO: Workshop root: ${WORKSHOP_ROOT} ***"

if [ ! -f "${LOG_FILE}" ]; then
  echo "*** INFO: Case fixer skipped (log not found) ***"
  exit 0
fi

if [ ! -d "${WORKSHOP_ROOT}" ]; then
  echo "*** INFO: Case fixer skipped (workshop root not found) ***"
  exit 0
fi

fixed_count=0
missing_count=0

grep -i "FileNotFoundException" "${LOG_FILE}" \
  | sed 's/.*FileNotFoundException: //' \
  | sed 's/ (No such file.*//' \
  | sort -u \
  | while IFS= read -r wrong_path; do
      wrong_path="$(echo "${wrong_path}" | tr -d '\r' | xargs)"

      [ -z "${wrong_path}" ] && continue
      [[ "${wrong_path}" != *"${MARKER}"* ]] && continue

      relative_path="${wrong_path#*${MARKER}}"
      workshop_id="${relative_path%%/*}"
      file_name="$(basename "${wrong_path}")"

      if [ -z "${workshop_id}" ] || [ "${workshop_id}" = "${relative_path}" ]; then
        continue
      fi

      search_base="${WORKSHOP_ROOT}/${workshop_id}"
      expected_full_path="${WORKSHOP_ROOT}/${relative_path}"

      if [ ! -d "${search_base}" ]; then
        echo "*** WARN: Case fixer: workshop ${workshop_id} not found ***"
        continue
      fi

      actual_full_path="$(find "${search_base}" -iname "${file_name}" -type f -print -quit)"

      if [ -z "${actual_full_path}" ]; then
        echo "*** WARN: Case fixer: no match for ${file_name} in workshop ${workshop_id} ***"
        missing_count=$((missing_count + 1))
        continue
      fi

      if [ "${actual_full_path}" = "${expected_full_path}" ]; then
        continue
      fi

      mkdir -p "$(dirname "${expected_full_path}")"

      if [ -e "${expected_full_path}" ] || [ -L "${expected_full_path}" ]; then
        continue
      fi

      ln -s "${actual_full_path}" "${expected_full_path}"
      echo "*** INFO: Case fixer: linked ${expected_full_path} -> ${actual_full_path} ***"
      fixed_count=$((fixed_count + 1))
    done

echo "*** INFO: Project Zomboid mod case fixer complete ***"