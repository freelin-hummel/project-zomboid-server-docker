# Init Pipeline (`init`)

This folder defines the end-to-end initialization flow used before starting the Project Zomboid dedicated server.

Canonical flow runner: `init/pipeline.sh`

Primary resolver implementation:

- Lua: `init/resolver.lua`

## Source of truth

- Optional per-mod `priority` (number) can be set on `mods[].mods[]` entries in `mods.json` to bias load order earlier; higher values load first when no dependency edge requires otherwise.

`import-mods.yml` entries are imported into `mods.json` during resolve, then `import-mods.yml` is cleaned based on resolver policy.

## Exact step-by-step flow

`pipeline.sh` runs 4 steps in order:

1. **Resolve** (`resolver.lua`)
   - Reads `import-mods.yml` and `mods.json`
   - Imports workshop/mod entries from `import-mods.yml` into registry
   - Scans metadata and resolves ordering data
   - Writes updated `mods.json` and cleans `import-mods.yml`

   Lua resolver adds dynamic role detection to reduce brittle static heuristics:

   - **library mods**: inferred from dependency in-degree (required by others)
   - **resource providers**: inferred from on-disk resources (maps/vehicles)
   - **global/API-touch signal**: inferred from core API token touches in Lua files

   Ordering is still dependency-safe (topological), with these dynamic signals used as tie-breakers.

2. **Download** (`download.py`)
   - Reads enabled workshop IDs from registry
   - Downloads required workshop items via SteamCMD

3. **Cleanup / verify** (`cleanup.py`)
   - Prunes stale workshop/cache artifacts
   - Verifies required workshop item presence

4. **Final runtime pass** (`resolver.lua --runtime-probe`)
   - Executes runtime sandbox probe on active Lua content
   - Detects runtime ordering/integration anomalies
   - Classifies dependencies as enabled / present-but-disabled / missing
   - Auto-enables present-but-disabled dependencies in `mods.json` by default
   - Writes text and JSON reports

## Pipeline controls

Main environment variables:

- `IMPORT_MODS_YML` (default: `/data/zomboid/import-mods.yml`)
- `MODS_YML` (compat alias)
- `MOD_CATALOG` (default: `/data/zomboid/init/mods.json`)
- `LAST_RUN_FILE` (default: `/data/zomboid/init/mods.last_run.json`)
- `STEAMAPPDIR` (required for download step)
- `WORKSHOP_APPID` (default: `108600`)
- `WORKSHOP_CONTENT_ROOT` (derived from `STEAMAPPDIR` if unset)
- `STEAMCMD_BIN` (default: `steamcmd`)
- `STEAM_LOGIN` (default: `anonymous`)
- `STEAMCMD_TIMEOUT_SECONDS` (default: `1800`)

Step toggles:

- `INIT_NO_DOWNLOAD=true` skips step 2
- `INIT_NO_CLEANUP=true` skips step 3
- `INIT_NO_LUA_CHECK=true` skips step 4

Final-pass report controls:

- `LUA_BIN` (default: `lua5.4`)
- `LUA_REPORT_TXT` (default: `/data/zomboid/init/stub-runtime-reorder-report.txt`)
- `LUA_REPORT_JSON` (default: `/data/zomboid/init/stub-runtime-report.json`)
- `LUA_RETRY_FROM_JSON` (optional seed report)
- `LUA_UMBRELLA_ROOT` (optional Lua stubs root)
- `LUA_MAX_ITEMS`, `LUA_MAX_FILES` (optional probe limits)

## Typical run

```sh
/bin/bash /data/zomboid/init/pipeline.sh
```

## What gets written

During a normal full run:

- `init/mods.json` may be updated by resolver and by final runtime autofix
- `init/mods.last_run.json` is updated by resolver/download with run bookkeeping
- `import-mods.yml` is reconciled/cleaned by resolver
- final-pass reports:
  - text: `LUA_REPORT_TXT`
  - json: `LUA_REPORT_JSON`

## Final-pass autofix behavior

When probe detects dependencies with status `present-but-not-enabled`, it enables them in `mods.json` and stamps:

- `addedAutomatically: true`
- `addedAutomaticallyReason: dependency-autofix`
- `addedAutomaticallyAt: <UTC timestamp>`

This behavior is default in pipeline final pass.