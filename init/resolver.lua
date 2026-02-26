#!/usr/bin/env lua

local function stderr(msg)
  io.stderr:write(msg .. "\n")
end

local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function shell_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function is_file(path)
  local f = io.open(path, "rb")
  if f then f:close(); return true end
  return false
end

local function is_dir(path)
  local p = io.popen("test -d " .. shell_quote(path) .. " && echo 1 || true")
  if not p then return false end
  local out = p:read("*a") or ""
  p:close()
  return out:match("1") ~= nil
end

local function default_last_run_path(registry_path)
  local base = tostring(registry_path or "")
  local stem, ext = base:match("^(.*)%.([^.]+)$")
  if stem and ext then
    return stem .. ".last_run." .. ext
  end
  return base .. ".last_run.json"
end

local function read_lines(path)
  local out = {}
  local f = io.open(path, "r")
  if not f then return out end
  for line in f:lines() do out[#out + 1] = line end
  f:close()
  return out
end

local function list_files_recursive(root, suffix)
  local files = {}
  local cmd = "find -L " .. shell_quote(root) .. " -type f"
  if suffix and suffix ~= "" then
    cmd = cmd .. " -name " .. shell_quote("*" .. suffix)
  end
  cmd = cmd .. " 2>/dev/null"
  local p = io.popen(cmd)
  if not p then return files end
  for abs in p:lines() do files[#files + 1] = abs end
  p:close()
  table.sort(files)
  return files
end

local function sorted_keys(map)
  local out = {}
  for k in pairs(map or {}) do out[#out + 1] = k end
  table.sort(out)
  return out
end

local function urldecode(s)
  s = tostring(s or "")
  s = s:gsub("%+", " ")
  s = s:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
  return s
end

local function normalize_mod_token(v)
  local s = trim(v or "")
  s = s:gsub("^[\\/]+", "")
  return s
end

local function parse_mods_blocks(path)
  local blocks = {}
  local current = nil
  for _, raw in ipairs(read_lines(path)) do
    local line = trim(raw)
    if line ~= "" and not line:match("^#") then
      if line == "---" then
        current = nil
      else
        local wid = line:match("^[Ww]orkshop%s+[Ii][Dd]%s*:%s*(%S+)")
        if wid then
          current = { workshop_id = wid, mod_ids = {} }
          blocks[#blocks + 1] = current
        elseif current then
          local mid = line:match("^[Mm]od%s+[Ii][Dd]%s*:%s*(.+)$")
          if mid then
            mid = trim(mid)
            if mid ~= "" then
              current.mod_ids[#current.mod_ids + 1] = mid
            end
          end
        end
      end
    end
  end
  return blocks
end

local function write_clean_mods_yml(path)
  local fh, err = io.open(path, "w")
  if not fh then return false, err end
  fh:write("# import-mods.yml is an import-only feed; it may be emptied by resolver after import.\n")
  fh:write("# Format:\n")
  fh:write("#   Workshop ID: <id>\n")
  fh:write("#   Mod ID: <id>   (optional, 0+)\n")
  fh:write("#   ---\n")
  fh:close()
  return true, nil
end

local function load_registry_entries(registry_path)
  local function split_tsv(line)
    local out = {}
    local s = tostring(line or "") .. "\t"
    for field in s:gmatch("(.-)\t") do
      out[#out + 1] = field
    end
    return out
  end

  local cmd = "python3 - " .. shell_quote(registry_path) .. " <<'PY'\n"
    .. "import json,sys,urllib.parse\n"
    .. "p=sys.argv[1]\n"
    .. "with open(p,'r',encoding='utf-8') as f:data=json.load(f)\n"
    .. "mods=data.get('mods',[])\n"
    .. "ov=data.get('overrides',{})\n"
    .. "if not isinstance(ov,dict): ov={}\n"
    .. "ra=ov.get('requireAliases',{})\n"
    .. "if not isinstance(ra,dict): ra={}\n"
    .. "for k,v in ra.items():\n"
    .. "  ks=urllib.parse.quote(str(k).strip(),safe='')\n"
    .. "  vs=urllib.parse.quote(str(v).strip(),safe='')\n"
    .. "  if ks and vs:\n"
    .. "    print(f'R\\t{ks}\\t{vs}')\n"
    .. "if not isinstance(mods,list): mods=[]\n"
    .. "for i,w in enumerate(mods):\n"
    .. "  if not isinstance(w,dict): continue\n"
    .. "  wid=str(w.get('workshopId','')).strip()\n"
    .. "  if not wid: continue\n"
    .. "  name=urllib.parse.quote(str(w.get('name','')),safe='')\n"
    .. "  print(f'W\\t{wid}\\t{name}\\t{i}')\n"
    .. "  arr=w.get('mods',[])\n"
    .. "  if not isinstance(arr,list): arr=[]\n"
    .. "  for j,m in enumerate(arr):\n"
    .. "    if not isinstance(m,dict): continue\n"
    .. "    mid=str(m.get('id','')).strip()\n"
    .. "    if not mid: continue\n"
    .. "    enabled='1' if bool(m.get('enabled',False)) else '0'\n"
    .. "    mname=urllib.parse.quote(str(m.get('name','')),safe='')\n"
    .. "    req=m.get('requires',[])\n"
    .. "    if isinstance(req,list): req='|'.join(str(x).strip() for x in req if str(x).strip())\n"
    .. "    elif isinstance(req,str): req=req\n"
    .. "    else: req=''\n"
    .. "    req=urllib.parse.quote(req,safe='')\n"
    .. "    vmin=urllib.parse.quote(str(m.get('versionMin','')),safe='')\n"
    .. "    pv=urllib.parse.quote(str(m.get('pzversion','')),safe='')\n"
    .. "    aa='1' if bool(m.get('addedAutomatically',False)) else '0'\n"
    .. "    aar=urllib.parse.quote(str(m.get('addedAutomaticallyReason','')),safe='')\n"
    .. "    aat=urllib.parse.quote(str(m.get('addedAutomaticallyAt','')),safe='')\n"
    .. "    pr=m.get('priority',None)\n"
    .. "    if isinstance(pr,bool):\n"
    .. "      pr=''\n"
    .. "    elif isinstance(pr,(int,float)):\n"
    .. "      pr=str(int(pr))\n"
    .. "    elif isinstance(pr,str) and pr.strip():\n"
    .. "      try: pr=str(int(pr.strip()))\n"
    .. "      except Exception: pr=''\n"
    .. "    else:\n"
    .. "      pr=''\n"
    .. "    print('M\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%d' % (wid,mid,enabled,mname,req,vmin,pv,aa,aar,aat,pr,j))\n"
    .. "PY"

  local p = io.popen(cmd)
  if not p then return nil, "failed to parse registry" end

  local entries_by_wid = {}
  local workshop_order = {}
  local seen_w = {}
  local require_aliases = {}

  for line in p:lines() do
    local parts = split_tsv(line)
    if parts[1] == "W" then
      local wid = trim(parts[2] or "")
      if wid ~= "" and not seen_w[wid] then
        seen_w[wid] = true
        workshop_order[#workshop_order + 1] = wid
        entries_by_wid[wid] = {
          workshopId = wid,
          name = urldecode(parts[3] or ""),
          mods = {},
        }
      end
    elseif parts[1] == "M" then
      local wid = trim(parts[2] or "")
      local mid = trim(parts[3] or "")
      if wid ~= "" and mid ~= "" then
        entries_by_wid[wid] = entries_by_wid[wid] or { workshopId = wid, name = "", mods = {} }
        local req_csv = urldecode(parts[6] or "")
        local requires = {}
        for token in tostring(req_csv):gmatch("[^|]+") do
          token = normalize_mod_token(token)
          if token ~= "" then requires[#requires + 1] = token end
        end
        entries_by_wid[wid].mods[#entries_by_wid[wid].mods + 1] = {
          id = mid,
          enabled = tostring(parts[4] or "0") == "1",
          name = urldecode(parts[5] or ""),
          requires = requires,
          versionMin = urldecode(parts[7] or ""),
          pzversion = urldecode(parts[8] or ""),
          addedAutomatically = tostring(parts[9] or "0") == "1",
          addedAutomaticallyReason = urldecode(parts[10] or ""),
          addedAutomaticallyAt = urldecode(parts[11] or ""),
          priority = tonumber(parts[12] or ""),
          _orig_idx = tonumber(parts[13] or "0") or 0,
        }
      end
    elseif parts[1] == "R" then
      local from = normalize_mod_token(urldecode(parts[2] or ""))
      local to = normalize_mod_token(urldecode(parts[3] or ""))
      if from ~= "" and to ~= "" then
        require_aliases[from] = to
      end
    end
  end
  p:close()

  return {
    entries_by_wid = entries_by_wid,
    workshop_order = workshop_order,
    require_aliases = require_aliases,
  }, nil
end

local function parse_mod_info(path)
  local out = {
    id = "",
    name = "",
    requires = {},
    versionMin = "",
    pzversion = "",
    tiledef_count = 0,
  }

  local seen_req = {}
  for _, line in ipairs(read_lines(path)) do
    local k, v = line:match("^%s*(%w+)%s*=%s*(.-)%s*$")
    if k and v then
      local kl = k:lower()
      if kl == "id" then
        out.id = normalize_mod_token(v)
      elseif kl == "name" then
        out.name = trim(v)
      elseif kl == "require" then
        for token in tostring(v):gmatch("([^,]+)") do
          local dep = normalize_mod_token(token)
          if dep ~= "" and not seen_req[dep] then
            seen_req[dep] = true
            out.requires[#out.requires + 1] = dep
          end
        end
      elseif kl == "versionmin" then
        out.versionMin = trim(v)
      elseif kl == "pzversion" then
        out.pzversion = trim(v)
      elseif kl == "tiledef" then
        out.tiledef_count = out.tiledef_count + 1
      end
    end
  end

  return out
end

local CORE_API_PATTERNS = {
  "Events", "ModData", "SandboxVars", "GameTime", "getGameTime", "getPlayer", "getWorld",
  "TraitFactory", "ProfessionFactory", "PerkFactory", "ScriptManager", "LuaEventManager",
}

local UI_API_PATTERNS = {
  "ISUI", "ISPanel", "ISButton", "ISCollapsableWindow", "ISScrollingListBox",
}

local function scan_workshop_item(workshop_root, wid)
  local item_dir = workshop_root .. "/" .. wid
  local out = {
    exists = is_dir(item_dir),
    modinfos = {},
    provides_maps = false,
    provides_vehicles = false,
    api_touch_count = 0,
    ui_touch_count = 0,
  }

  if not out.exists then
    return out
  end

  local modinfo_paths = list_files_recursive(item_dir, "mod.info")
  for _, mpath in ipairs(modinfo_paths) do
    local mi = parse_mod_info(mpath)
    if mi.id ~= "" then
      out.modinfos[#out.modinfos + 1] = mi
    end
  end

  local maps_cmd = "find -L " .. shell_quote(item_dir) .. " -type d -path '*/media/maps/*' 2>/dev/null | head -n 1"
  local p_maps = io.popen(maps_cmd)
  if p_maps then
    out.provides_maps = trim(p_maps:read("*a") or "") ~= ""
    p_maps:close()
  end

  local veh_cmd = "find -L " .. shell_quote(item_dir) .. " -type f \\( -path '*/media/scripts/vehicles/*' -o -path '*/media/vehicles/*' \\) 2>/dev/null | head -n 1"
  local p_veh = io.popen(veh_cmd)
  if p_veh then
    out.provides_vehicles = trim(p_veh:read("*a") or "") ~= ""
    p_veh:close()
  end

  local touched_core = {}
  local touched_ui = {}
  local lua_files = list_files_recursive(item_dir, ".lua")
  for _, lpath in ipairs(lua_files) do
    for _, line in ipairs(read_lines(lpath)) do
      for _, token in ipairs(CORE_API_PATTERNS) do
        if not touched_core[token] and line:find(token, 1, true) then touched_core[token] = true end
      end
      for _, token in ipairs(UI_API_PATTERNS) do
        if not touched_ui[token] and line:find(token, 1, true) then touched_ui[token] = true end
      end
    end
  end

  for _ in pairs(touched_core) do out.api_touch_count = out.api_touch_count + 1 end
  for _ in pairs(touched_ui) do out.ui_touch_count = out.ui_touch_count + 1 end

  return out
end

local function ensure_mod(entry, mod_id)
  for _, m in ipairs(entry.mods) do
    if m.id == mod_id then return m end
  end
  local m = {
    id = mod_id,
    enabled = true,
    name = "",
    requires = {},
    versionMin = "",
    pzversion = "",
    priority = nil,
    addedAutomatically = false,
    addedAutomaticallyReason = "",
    addedAutomaticallyAt = "",
    _orig_idx = #entry.mods,
  }
  entry.mods[#entry.mods + 1] = m
  return m
end

local function apply_import_blocks(reg, blocks)
  local imported_workshops = {}
  local imported_mods = {}
  local explicit_selection = {}

  local seen_import_w = {}
  local seen_import_m = {}
  local order_seen = {}
  for _, wid in ipairs(reg.workshop_order) do order_seen[wid] = true end

  for _, b in ipairs(blocks) do
    local wid = trim(b.workshop_id or "")
    if wid ~= "" then
      reg.entries_by_wid[wid] = reg.entries_by_wid[wid] or { workshopId = wid, name = "", mods = {} }
      if not order_seen[wid] then
        reg.workshop_order[#reg.workshop_order + 1] = wid
        order_seen[wid] = true
      end

      if not seen_import_w[wid] then
        seen_import_w[wid] = true
        imported_workshops[#imported_workshops + 1] = wid
      end

      if #b.mod_ids > 0 then
        explicit_selection[wid] = explicit_selection[wid] or {}
        for _, mid in ipairs(b.mod_ids) do
          mid = normalize_mod_token(mid)
          if mid ~= "" then
            explicit_selection[wid][mid] = true
            if not seen_import_m[mid] then
              seen_import_m[mid] = true
              imported_mods[#imported_mods + 1] = mid
            end
            ensure_mod(reg.entries_by_wid[wid], mid)
          end
        end
      end
    end
  end

  return {
    imported_workshops = imported_workshops,
    imported_mods = imported_mods,
    explicit_selection = explicit_selection,
  }
end

local function enrich_with_scan(reg, workshop_root)
  local scan_by_wid = {}
  local existing_wids = {}
  for _, wid in ipairs(reg.workshop_order) do existing_wids[wid] = true end
  for wid in pairs(reg.entries_by_wid) do
    if not existing_wids[wid] then
      reg.workshop_order[#reg.workshop_order + 1] = wid
      existing_wids[wid] = true
    end
  end

  for _, wid in ipairs(reg.workshop_order) do
    local scan = scan_workshop_item(workshop_root, wid)
    scan_by_wid[wid] = scan
    if scan.exists then
      local entry = reg.entries_by_wid[wid]
      for _, mi in ipairs(scan.modinfos) do
        local m = ensure_mod(entry, mi.id)
        if mi.name ~= "" then m.name = mi.name end
        if #mi.requires > 0 then m.requires = mi.requires end
        if mi.versionMin ~= "" then m.versionMin = mi.versionMin end
        if mi.pzversion ~= "" then m.pzversion = mi.pzversion end
      end
    end
  end

  return scan_by_wid
end

local function apply_explicit_selection(reg, explicit_selection)
  for wid, sel in pairs(explicit_selection or {}) do
    local entry = reg.entries_by_wid[wid]
    if entry then
      for _, m in ipairs(entry.mods) do
        m.enabled = sel[m.id] == true
      end
      for mid in pairs(sel) do
        local found = false
        for _, m in ipairs(entry.mods) do if m.id == mid then found = true break end end
        if not found then
          entry.mods[#entry.mods + 1] = {
            id = mid,
            enabled = true,
            name = mid,
            requires = {},
            versionMin = "",
            pzversion = "",
            priority = nil,
            addedAutomatically = false,
            addedAutomaticallyReason = "",
            addedAutomaticallyAt = "",
            _orig_idx = #entry.mods,
          }
        end
      end
    end
  end
end

local function build_enabled_mod_index(reg)
  local enabled_mods = {}
  local mod_to_wid = {}
  local mod_requires = {}
  local mod_priority = {}
  local orig_rank = {}
  local duplicates = {}

  local rank = 0
  for _, wid in ipairs(reg.workshop_order) do
    local entry = reg.entries_by_wid[wid]
    if entry then
      for idx, m in ipairs(entry.mods) do
        if m.enabled then
          if not mod_to_wid[m.id] then
            enabled_mods[#enabled_mods + 1] = m.id
            mod_to_wid[m.id] = wid
            mod_requires[m.id] = m.requires or {}
            mod_priority[m.id] = tonumber(m.priority or 0) or 0
            rank = rank + 1
            orig_rank[m.id] = rank
          else
            duplicates[#duplicates + 1] = { mod_id = m.id, first = mod_to_wid[m.id], second = wid }
          end
        end
        m._orig_idx = m._orig_idx or idx
      end
    end
  end

  return {
    enabled_mods = enabled_mods,
    mod_to_wid = mod_to_wid,
    mod_requires = mod_requires,
    mod_priority = mod_priority,
    orig_rank = orig_rank,
    duplicates = duplicates,
  }
end

local function resolve_order(reg, scan_by_wid)
  local idx = build_enabled_mod_index(reg)
  local enabled_set = {}
  for _, mid in ipairs(idx.enabled_mods) do enabled_set[mid] = true end

  local incoming = {}
  local outgoing = {}
  local indegree = {}
  local inbound_count = {}
  local missing = {}

  for _, mid in ipairs(idx.enabled_mods) do
    incoming[mid] = {}
    outgoing[mid] = {}
    indegree[mid] = 0
    inbound_count[mid] = 0
  end

  for _, mid in ipairs(idx.enabled_mods) do
    for _, dep in ipairs(idx.mod_requires[mid] or {}) do
      dep = normalize_mod_token(dep)
      if dep ~= "" then
        local resolved_dep = normalize_mod_token((reg.require_aliases or {})[dep] or dep)
        if resolved_dep ~= "" and enabled_set[resolved_dep] then
          if not incoming[mid][resolved_dep] then
            incoming[mid][resolved_dep] = true
            outgoing[resolved_dep][mid] = true
            indegree[mid] = indegree[mid] + 1
            inbound_count[resolved_dep] = inbound_count[resolved_dep] + 1
          end
        else
          missing[dep] = missing[dep] or {}
          missing[dep][#missing[dep] + 1] = mid
        end
      end
    end
  end

  local score = {}
  local role = {}
  for _, mid in ipairs(idx.enabled_mods) do
    local wid = idx.mod_to_wid[mid]
    local scan = scan_by_wid[wid] or {}
    local provides_maps = scan.provides_maps == true
    local provides_vehicles = scan.provides_vehicles == true
    local api_touch = tonumber(scan.api_touch_count or 0) or 0
    local ui_touch = tonumber(scan.ui_touch_count or 0) or 0
    local inbound = inbound_count[mid] or 0

    local is_library = inbound > 0 and (not provides_maps) and (not provides_vehicles)
    local is_resource_provider = provides_maps or provides_vehicles

    role[mid] = {
      library = is_library,
      resource_provider = is_resource_provider,
      provides_maps = provides_maps,
      provides_vehicles = provides_vehicles,
      inbound = inbound,
      api_touch = api_touch,
      ui_touch = ui_touch,
    }

    local s = 0
    if is_library then s = s + 200 end
    if is_resource_provider then s = s + 80 end
    s = s + math.min(20, inbound) * 10
    s = s + math.min(20, api_touch)
    if ui_touch > 0 and (not is_library) and (not is_resource_provider) then
      s = s - 20
    end
    score[mid] = s
  end

  local queue = {}
  for _, mid in ipairs(idx.enabled_mods) do
    if indegree[mid] == 0 then queue[#queue + 1] = mid end
  end

  local function qsort()
    table.sort(queue, function(a, b)
      local pa, pb = idx.mod_priority[a] or 0, idx.mod_priority[b] or 0
      if pa ~= pb then return pa > pb end
      local sa, sb = score[a] or 0, score[b] or 0
      if sa ~= sb then return sa > sb end
      local ra, rb = idx.orig_rank[a] or 10^9, idx.orig_rank[b] or 10^9
      if ra ~= rb then return ra < rb end
      return a < b
    end)
  end

  qsort()
  local ordered = {}
  while #queue > 0 do
    local mid = table.remove(queue, 1)
    ordered[#ordered + 1] = mid
    for nxt in pairs(outgoing[mid]) do
      indegree[nxt] = indegree[nxt] - 1
      if indegree[nxt] == 0 then
        queue[#queue + 1] = nxt
      end
    end
    qsort()
  end

  local ordered_set = {}
  for _, mid in ipairs(ordered) do ordered_set[mid] = true end
  local cycles = {}
  for _, mid in ipairs(idx.enabled_mods) do
    if not ordered_set[mid] then cycles[#cycles + 1] = mid end
  end

  if #cycles > 0 then
    table.sort(cycles)
    for _, mid in ipairs(idx.enabled_mods) do
      if not ordered_set[mid] then ordered[#ordered + 1] = mid end
    end
  end

  local ordered_pos = {}
  for i, mid in ipairs(ordered) do ordered_pos[mid] = i end

  return {
    ordered_mods = ordered,
    ordered_pos = ordered_pos,
    missing = missing,
    cycles = cycles,
    duplicates = idx.duplicates,
    role = role,
    mod_to_wid = idx.mod_to_wid,
  }
end

local function reorder_registry(reg, resolution)
  local ws_rank = {}
  local orig_ws_rank = {}
  for i, wid in ipairs(reg.workshop_order) do orig_ws_rank[wid] = i end

  for _, wid in ipairs(reg.workshop_order) do
    local entry = reg.entries_by_wid[wid]
    local best = 10^9
    if entry then
      for _, m in ipairs(entry.mods) do
        if m.enabled and resolution.ordered_pos[m.id] and resolution.ordered_pos[m.id] < best then
          best = resolution.ordered_pos[m.id]
        end
      end
    end
    ws_rank[wid] = best
  end

  table.sort(reg.workshop_order, function(a, b)
    local ra, rb = ws_rank[a] or 10^9, ws_rank[b] or 10^9
    if ra ~= rb then return ra < rb end
    return (orig_ws_rank[a] or 10^9) < (orig_ws_rank[b] or 10^9)
  end)

  for _, wid in ipairs(reg.workshop_order) do
    local entry = reg.entries_by_wid[wid]
    if entry then
      table.sort(entry.mods, function(a, b)
        local pa = a.enabled and (resolution.ordered_pos[a.id] or 10^9) or (10^9 + (a._orig_idx or 0))
        local pb = b.enabled and (resolution.ordered_pos[b.id] or 10^9) or (10^9 + (b._orig_idx or 0))
        if pa ~= pb then return pa < pb end
        return (a._orig_idx or 0) < (b._orig_idx or 0)
      end)
    end
  end
end

local function to_json(v)
  local tv = type(v)
  if tv == "nil" then return "null" end
  if tv == "boolean" then return v and "true" or "false" end
  if tv == "number" then return tostring(v) end
  if tv == "string" then
    local s = v:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r")
    return '"' .. s .. '"'
  end
  if tv == "table" then
    local is_arr = true
    local n = 0
    for k in pairs(v) do
      if type(k) ~= "number" then is_arr = false break end
      if k > n then n = k end
    end
    if is_arr then
      for i = 1, n do if v[i] == nil then is_arr = false break end end
    end
    if is_arr then
      local parts = {}
      for i = 1, n do parts[#parts + 1] = to_json(v[i]) end
      return "[" .. table.concat(parts, ",") .. "]"
    else
      local keys = sorted_keys(v)
      local parts = {}
      for _, k in ipairs(keys) do
        parts[#parts + 1] = to_json(k) .. ":" .. to_json(v[k])
      end
      return "{" .. table.concat(parts, ",") .. "}"
    end
  end
  return '"<unsupported>"'
end

local function make_proxy(path)
  local proxy = {}
  local mt
  mt = {
    __index = function(_, k)
      if type(k) == "number" then return nil end
      return make_proxy(path .. "." .. tostring(k))
    end,
    __newindex = function() end,
    __call = function() return make_proxy(path .. "()") end,
    __add = function() return make_proxy(path .. "+") end,
    __sub = function() return make_proxy(path .. "-") end,
    __mul = function() return make_proxy(path .. "*") end,
    __div = function() return make_proxy(path .. "/") end,
    __mod = function() return make_proxy(path .. "%") end,
    __pow = function() return make_proxy(path .. "^") end,
    __unm = function() return make_proxy("-" .. path) end,
    __concat = function() return make_proxy(path .. "..") end,
    __len = function() return 0 end,
    __eq = function() return false end,
    __lt = function() return false end,
    __le = function() return false end,
    __pairs = function() return function() return nil end, {}, nil end,
    __tostring = function() return "<stub:" .. path .. ">" end,
  }
  return setmetatable(proxy, mt)
end

local function load_retry_ranks_from_json(path)
  if not path or trim(path) == "" or (not is_file(path)) then return {} end
  local cmd = "python3 - " .. shell_quote(path) .. " <<'PY'\n"
    .. "import json,sys\n"
    .. "p=sys.argv[1]\n"
    .. "with open(p,'r',encoding='utf-8') as f:data=json.load(f)\n"
    .. "for i,fp in enumerate(data.get('ordered_files',[]) or [], start=1):\n"
    .. "  if isinstance(fp,str) and fp:\n"
    .. "    print(f'{i}\\t{fp}')\n"
    .. "PY"
  local p = io.popen(cmd)
  if not p then return {} end
  local ranks = {}
  for line in p:lines() do
    local rank, fp = line:match("^(%d+)\t(.+)$")
    if rank and fp then ranks[fp] = tonumber(rank) end
  end
  p:close()
  return ranks
end

local function apply_retry_order(files, ranks)
  if not ranks or next(ranks) == nil then return files end
  local out, raw_index = {}, {}
  for i, f in ipairs(files) do
    out[i] = f
    raw_index[f.file] = i
  end
  table.sort(out, function(a, b)
    local ra, rb = ranks[a.file], ranks[b.file]
    if ra and rb then return ra < rb end
    if ra and not rb then return true end
    if rb and not ra then return false end
    return (raw_index[a.file] or 10^9) < (raw_index[b.file] or 10^9)
  end)
  return out
end

local function make_runtime(issues)
  local safe_os = {
    clock = os.clock,
    date = os.date,
    difftime = os.difftime,
    time = os.time,
  }

  local runtime = {
    assert = assert,
    error = error,
    ipairs = ipairs,
    next = next,
    pairs = pairs,
    pcall = pcall,
    select = select,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    xpcall = xpcall,
    print = print,
    math = math,
    string = string,
    table = table,
    utf8 = utf8,
    coroutine = coroutine,
    os = safe_os,
    _VERSION = _VERSION,
  }

  local current_context = { owner = "<bootstrap>", file = "" }
  local global_defs = {}
  local event_callbacks = {}

  local function make_event(name)
    local e = {}
    function e.Add(fn)
      if type(fn) == "function" then
        event_callbacks[name] = event_callbacks[name] or {}
        event_callbacks[name][#event_callbacks[name] + 1] = fn
      end
      return fn
    end
    function e.Remove(fn)
      local list = event_callbacks[name] or {}
      for i = #list, 1, -1 do
        if list[i] == fn then table.remove(list, i) end
      end
    end
    return e
  end

  runtime.Events = setmetatable({}, {
    __index = function(t, k)
      local e = make_event(tostring(k))
      rawset(t, k, e)
      return e
    end
  })

  runtime.require = function(name)
    issues.require_fallbacks[name] = (issues.require_fallbacks[name] or 0) + 1
    runtime.package = runtime.package or { loaded = {} }
    runtime.package.loaded[name] = runtime.package.loaded[name] or make_proxy("require(" .. tostring(name) .. ")")
    return runtime.package.loaded[name]
  end

  local mt = {
    __index = function(_, k)
      local key = tostring(k)
      issues.missing_globals[key] = (issues.missing_globals[key] or 0) + 1
      if current_context.file and current_context.file ~= "" then
        issues.file_missing_globals[current_context.file] = issues.file_missing_globals[current_context.file] or {}
        issues.file_missing_globals[current_context.file][key] = (issues.file_missing_globals[current_context.file][key] or 0) + 1
      end
      local p = make_proxy(key)
      rawset(runtime, k, p)
      return p
    end,
    __newindex = function(_, k, v)
      local key = tostring(k)
      local prev = rawget(runtime, k)
      local prev_kind = type(prev)
      local new_kind = type(v)

      if prev ~= nil and prev ~= v and prev_kind == "function" and new_kind == "function" then
        issues.global_overrides[#issues.global_overrides + 1] = {
          symbol = key,
          prev_owner = (global_defs[key] and global_defs[key].owner) or "<unknown>",
          new_owner = current_context.owner,
          file = current_context.file,
        }
      end

      rawset(runtime, k, v)
      global_defs[key] = { owner = current_context.owner, file = current_context.file }

      if current_context.file and current_context.file ~= "" then
        issues.file_defined_globals[current_context.file] = issues.file_defined_globals[current_context.file] or {}
        issues.file_defined_globals[current_context.file][key] = true
      end
    end,
  }

  setmetatable(runtime, mt)

  local function exec_file(path, owner, bucket)
    local t0 = os.clock()
    current_context.owner = owner
    current_context.file = path
    local chunk, lerr = loadfile(path, "t", runtime)
    if not chunk then
      bucket[#bucket + 1] = { file = path, err = lerr }
      return false, { elapsed = os.clock() - t0, timed_out = false }
    end

    local timeout_msg = "instruction limit exceeded while executing chunk"
    local function hook() error(timeout_msg, 0) end
    debug.sethook(hook, "", 2000000)
    local ok, rerr = pcall(chunk)
    debug.sethook()
    local elapsed = os.clock() - t0

    if not ok then
      local msg = tostring(rerr)
      local timed_out = msg:find(timeout_msg, 1, true) ~= nil
      bucket[#bucket + 1] = { file = path, err = msg, timed_out = timed_out, elapsed = elapsed }
      return false, { elapsed = elapsed, timed_out = timed_out }
    end
    return true, { elapsed = elapsed, timed_out = false }
  end

  local function run_event_callbacks()
    local event_names = sorted_keys(event_callbacks)
    for _, ev in ipairs(event_names) do
      local callbacks = event_callbacks[ev]
      for i, fn in ipairs(callbacks) do
        local timeout_msg = "instruction limit exceeded while executing callback"
        local function hook() error(timeout_msg, 0) end
        debug.sethook(hook, "", 1000000)
        local ok, err = pcall(fn, make_proxy("arg1"), make_proxy("arg2"), make_proxy("arg3"))
        debug.sethook()
        if not ok then
          issues.event_callback_errors[#issues.event_callback_errors + 1] = {
            event = ev,
            idx = i,
            err = tostring(err),
            timed_out = tostring(err):find(timeout_msg, 1, true) ~= nil,
          }
        end
      end
    end
  end

  return {
    exec_file = exec_file,
    run_event_callbacks = run_event_callbacks,
  }
end

local function collect_mod_lua_files(reg, workshop_root, max_items, max_files)
  local files = {}
  local counts = { items_on_disk = 0, files = 0 }
  local items_seen = 0
  max_items = tonumber(max_items or 0) or 0
  max_files = tonumber(max_files or 0) or 0

  for _, wid in ipairs(reg.workshop_order or {}) do
    local entry = reg.entries_by_wid[wid]
    local has_enabled = false
    if entry then
      for _, m in ipairs(entry.mods or {}) do
        if m.enabled then has_enabled = true break end
      end
    end
    if has_enabled then
      if max_items > 0 and items_seen >= max_items then break end
      local item_dir = workshop_root .. "/" .. wid
      if is_dir(item_dir) then
        items_seen = items_seen + 1
        counts.items_on_disk = counts.items_on_disk + 1
        local item_files = list_files_recursive(item_dir, ".lua")
        for _, path in ipairs(item_files) do
          files[#files + 1] = { workshop_id = wid, file = path }
          counts.files = counts.files + 1
          if max_files > 0 and counts.files >= max_files then break end
        end
        if max_files > 0 and counts.files >= max_files then break end
      end
    end
  end

  table.sort(files, function(a, b)
    if a.workshop_id == b.workshop_id then return a.file < b.file end
    return a.workshop_id < b.workshop_id
  end)
  return files, counts
end

local function build_runtime_order(files, file_defined_globals, file_missing_globals)
  local key_to_file, raw_index = {}, {}
  for i, f in ipairs(files) do
    local key = f.workshop_id .. "|" .. f.file
    key_to_file[key] = f
    raw_index[key] = i
  end

  local providers = {}
  for fpath, defs in pairs(file_defined_globals or {}) do
    for sym in pairs(defs) do
      providers[sym] = providers[sym] or {}
      providers[sym][#providers[sym] + 1] = fpath
    end
  end

  local indegree, outgoing = {}, {}
  for key in pairs(key_to_file) do
    indegree[key] = 0
    outgoing[key] = {}
  end

  local edge_count = 0
  for fpath, miss in pairs(file_missing_globals or {}) do
    local consumer_key
    for key, f in pairs(key_to_file) do
      if f.file == fpath then consumer_key = key break end
    end
    if consumer_key then
      for sym in pairs(miss) do
        local pfiles = providers[sym] or {}
        for _, pfile in ipairs(pfiles) do
          if pfile ~= fpath then
            local provider_key
            for key, f in pairs(key_to_file) do
              if f.file == pfile then provider_key = key break end
            end
            if provider_key and not outgoing[provider_key][consumer_key] then
              outgoing[provider_key][consumer_key] = true
              indegree[consumer_key] = indegree[consumer_key] + 1
              edge_count = edge_count + 1
            end
          end
        end
      end
    end
  end

  local queue = {}
  for key, deg in pairs(indegree) do if deg == 0 then queue[#queue + 1] = key end end
  table.sort(queue, function(a, b) return (raw_index[a] or 10^9) < (raw_index[b] or 10^9) end)

  local ordered_keys, head = {}, 1
  while head <= #queue do
    local k = queue[head]
    head = head + 1
    ordered_keys[#ordered_keys + 1] = k

    local nexts = {}
    for nk in pairs(outgoing[k]) do nexts[#nexts + 1] = nk end
    table.sort(nexts, function(a, b) return (raw_index[a] or 10^9) < (raw_index[b] or 10^9) end)

    for _, nk in ipairs(nexts) do
      indegree[nk] = indegree[nk] - 1
      if indegree[nk] == 0 then queue[#queue + 1] = nk end
    end
  end

  local seen = {}
  for _, k in ipairs(ordered_keys) do seen[k] = true end
  if #ordered_keys < #files then
    local leftovers = {}
    for key in pairs(key_to_file) do
      if not seen[key] then leftovers[#leftovers + 1] = key end
    end
    table.sort(leftovers, function(a, b) return (raw_index[a] or 10^9) < (raw_index[b] or 10^9) end)
    for _, k in ipairs(leftovers) do ordered_keys[#ordered_keys + 1] = k end
  end

  local ordered_files = {}
  for _, k in ipairs(ordered_keys) do ordered_files[#ordered_files + 1] = key_to_file[k] end
  return ordered_files, edge_count
end

local function collect_order_anomalies(raw_files, ordered_files)
  local raw_pos = {}
  for i, f in ipairs(raw_files) do raw_pos[f.workshop_id .. "|" .. f.file] = i end
  local anomalies = {}
  for i, f in ipairs(ordered_files) do
    local key = f.workshop_id .. "|" .. f.file
    local rpos = raw_pos[key] or i
    if rpos ~= i then
      anomalies[#anomalies + 1] = {
        workshop_id = f.workshop_id,
        file = f.file,
        raw_pos = rpos,
        safe_pos = i,
      }
    end
  end
  return anomalies
end

local function collect_dependency_presence(reg)
  local enabled_provides, all_provides = {}, {}
  for _, wid in ipairs(reg.workshop_order or {}) do
    local entry = reg.entries_by_wid[wid]
    if entry then
      for _, m in ipairs(entry.mods or {}) do
        if m.id and m.id ~= "" then
          all_provides[m.id] = all_provides[m.id] or {}
          all_provides[m.id][wid] = true
          if m.enabled then
            enabled_provides[m.id] = enabled_provides[m.id] or {}
            enabled_provides[m.id][wid] = true
          end
        end
      end
    end
  end

  local refs = {}
  for _, wid in ipairs(reg.workshop_order or {}) do
    local entry = reg.entries_by_wid[wid]
    if entry then
      for _, m in ipairs(entry.mods or {}) do
        if m.enabled then
          for _, dep in ipairs(m.requires or {}) do
            dep = normalize_mod_token(dep)
            if dep ~= "" then
              local resolved_dep = normalize_mod_token((reg.require_aliases or {})[dep] or dep)
              local in_enabled = enabled_provides[resolved_dep] ~= nil
              local in_all = all_provides[resolved_dep] ~= nil
              local status = "missing-on-disk"
              if in_enabled then status = "satisfied-enabled"
              elseif in_all then status = "present-but-not-enabled" end
              refs[#refs + 1] = {
                workshop_id = wid,
                mod_id = m.id,
                required = dep,
                requiredResolved = resolved_dep,
                status = status,
                providers_enabled = in_enabled and sorted_keys(enabled_provides[resolved_dep]) or {},
                providers_all = in_all and sorted_keys(all_provides[resolved_dep]) or {},
              }
            end
          end
        end
      end
    end
  end
  return refs
end

local function apply_registry_dependency_autofix(reg, dep_refs)
  local wanted = {}
  for _, ref in ipairs(dep_refs or {}) do
    if ref.status == "present-but-not-enabled" and ref.required and ref.required ~= "" then
      wanted[ref.required] = true
    end
  end
  local updated = {}
  if next(wanted) == nil then return updated end

  local now = os.date("!%Y-%m-%dT%H:%M:%SZ")
  for _, wid in ipairs(reg.workshop_order or {}) do
    local entry = reg.entries_by_wid[wid]
    if entry then
      for _, m in ipairs(entry.mods or {}) do
        if wanted[m.id] and (not m.enabled) then
          m.enabled = true
          m.addedAutomatically = true
          m.addedAutomaticallyReason = "dependency-autofix"
          m.addedAutomaticallyAt = now
          updated[#updated + 1] = m.id
        end
      end
    end
  end

  table.sort(updated)
  return updated
end

local function write_probe_report(path, counts, issues)
  if not path or trim(path) == "" then return true, nil end
  local fh, err = io.open(path, "w")
  if not fh then return false, err end
  fh:write("RUNTIME RESOLVER PROBE REPORT\n")
  fh:write(string.rep("=", 48) .. "\n")
  fh:write("workshop items scanned: " .. tostring(counts.items_on_disk or 0) .. "\n")
  fh:write("mod lua files scanned: " .. tostring(counts.mod_files or 0) .. "\n")
  fh:write("order anomalies: " .. tostring(#(issues.order_anomalies or {})) .. "\n")
  fh:write("runtime edges used: " .. tostring(counts.runtime_edges or 0) .. "\n")
  fh:write("analysis timeouts: " .. tostring(counts.analysis_timeouts or 0) .. "\n")
  fh:write("execute timeouts: " .. tostring(counts.execute_timeouts or 0) .. "\n")
  fh:write("registry auto-added: " .. tostring(counts.registry_auto_added_count or 0) .. "\n")

  if (issues.order_anomalies or {})[1] then
    fh:write("\nChanged entries:\n")
    for _, a in ipairs(issues.order_anomalies) do
      fh:write("- [" .. a.workshop_id .. "] raw#" .. a.raw_pos .. " -> safe#" .. a.safe_pos .. " " .. a.file .. "\n")
    end
  end
  if (counts.registry_auto_added or {})[1] then
    fh:write("\nAuto-enabled Mod IDs in registry:\n")
    for _, mid in ipairs(counts.registry_auto_added) do fh:write("- " .. mid .. "\n") end
  end
  fh:close()
  return true, nil
end

local function run_runtime_probe(reg, opts)
  local analysis_issues = {
    missing_globals = {}, require_fallbacks = {}, global_overrides = {}, event_callback_errors = {},
    stub_load_errors = {}, mod_load_errors = {}, file_missing_globals = {}, file_defined_globals = {},
  }
  local analysis_rt = make_runtime(analysis_issues)

  if opts.probe_umbrella_root and trim(opts.probe_umbrella_root) ~= "" and is_dir(opts.probe_umbrella_root) then
    local stub_files = list_files_recursive(opts.probe_umbrella_root, ".lua")
    for _, path in ipairs(stub_files) do
      analysis_rt.exec_file(path, "umbrella", analysis_issues.stub_load_errors)
    end
  end

  local raw_files, file_counts = collect_mod_lua_files(reg, opts.workshop_root, opts.probe_max_items, opts.probe_max_files)
  local retry_ranks = load_retry_ranks_from_json(opts.probe_retry_from_json)
  raw_files = apply_retry_order(raw_files, retry_ranks)

  local analysis_timeouts = 0
  for _, item in ipairs(raw_files) do
    local _, meta = analysis_rt.exec_file(item.file, "workshop:" .. item.workshop_id, analysis_issues.mod_load_errors)
    if meta and meta.timed_out then analysis_timeouts = analysis_timeouts + 1 end
  end

  local ordered_files, runtime_edges = build_runtime_order(raw_files, analysis_issues.file_defined_globals, analysis_issues.file_missing_globals)
  local anomalies = collect_order_anomalies(raw_files, ordered_files)

  local dep_refs = collect_dependency_presence(reg)
  local auto_added = {}
  if not opts.probe_no_registry_update then
    auto_added = apply_registry_dependency_autofix(reg, dep_refs)
  end

  local counts = {
    items_on_disk = file_counts.items_on_disk,
    mod_files = file_counts.files,
    runtime_edges = runtime_edges,
    analysis_timeouts = analysis_timeouts,
    execute_timeouts = 0,
    registry_auto_added = auto_added,
    registry_auto_added_count = #auto_added,
  }

  local dep_summary = {
    satisfied_enabled = 0,
    present_but_not_enabled = 0,
    missing_on_disk = 0,
  }
  for _, ref in ipairs(dep_refs) do
    if ref.status == "satisfied-enabled" then dep_summary.satisfied_enabled = dep_summary.satisfied_enabled + 1 end
    if ref.status == "present-but-not-enabled" then dep_summary.present_but_not_enabled = dep_summary.present_but_not_enabled + 1 end
    if ref.status == "missing-on-disk" then dep_summary.missing_on_disk = dep_summary.missing_on_disk + 1 end
  end

  local issues = {
    missing_globals = analysis_issues.missing_globals,
    require_fallbacks = analysis_issues.require_fallbacks,
    global_overrides = analysis_issues.global_overrides,
    event_callback_errors = analysis_issues.event_callback_errors,
    stub_load_errors = analysis_issues.stub_load_errors,
    mod_load_errors = analysis_issues.mod_load_errors,
    order_anomalies = anomalies,
    ordered_files = ordered_files,
    dependency_presence = dep_refs,
    dependency_presence_summary = dep_summary,
  }

  local ok_r, err_r = write_probe_report(opts.probe_report_file, counts, issues)
  if not ok_r then stderr("WARNING: failed to write probe report: " .. tostring(err_r)) end

  if opts.probe_json_report_file and trim(opts.probe_json_report_file) ~= "" then
    local ordered_paths = {}
    for _, f in ipairs(ordered_files) do ordered_paths[#ordered_paths + 1] = f.file end
    local payload = {
      version = 1,
      source = { registry = opts.registry, workshop_root = opts.workshop_root, retry_from_json = opts.probe_retry_from_json },
      counts = {
        items_on_disk = counts.items_on_disk,
        mod_files = counts.mod_files,
        runtime_edges = counts.runtime_edges,
        analysis_timeouts = counts.analysis_timeouts,
        execute_timeouts = counts.execute_timeouts,
        mod_load_errors = #(issues.mod_load_errors or {}),
        event_callback_errors = #(issues.event_callback_errors or {}),
        registry_auto_added_count = counts.registry_auto_added_count,
      },
      order_anomalies = anomalies,
      ordered_files = ordered_paths,
      dependency_presence_summary = dep_summary,
      dependency_presence = dep_refs,
      registry_auto_added = auto_added,
    }
    local fjson, jerr = io.open(opts.probe_json_report_file, "w")
    if fjson then
      fjson:write(to_json(payload))
      fjson:write("\n")
      fjson:close()
    else
      stderr("WARNING: failed to write probe json: " .. tostring(jerr))
    end
  end

  return { counts = counts, issues = issues }
end

local function build_compact_mods_list(reg)
  local out = {}
  for _, wid in ipairs(reg.workshop_order) do
    local entry = reg.entries_by_wid[wid]
    if entry then
      local mods = {}
      for _, m in ipairs(entry.mods) do
        local obj = {
          id = m.id,
          enabled = m.enabled == true,
        }
        if trim(m.name) ~= "" then obj.name = m.name end
        if (m.requires or {})[1] then obj.requires = m.requires end
        if trim(m.versionMin or "") ~= "" then obj.versionMin = m.versionMin end
        if trim(m.pzversion or "") ~= "" then obj.pzversion = m.pzversion end
        if tonumber(m.priority) ~= nil then obj.priority = tonumber(m.priority) end
        if m.addedAutomatically then obj.addedAutomatically = true end
        if trim(m.addedAutomaticallyReason or "") ~= "" then obj.addedAutomaticallyReason = m.addedAutomaticallyReason end
        if trim(m.addedAutomaticallyAt or "") ~= "" then obj.addedAutomaticallyAt = m.addedAutomaticallyAt end
        mods[#mods + 1] = obj
      end
      out[#out + 1] = {
        workshopId = wid,
        name = entry.name or "",
        mods = mods,
      }
    end
  end
  return out
end

local function write_registry(registry_path, last_run_path, mods_list, summary)
  local mods_tmp = os.tmpname()
  local sum_tmp = os.tmpname()

  local f1 = assert(io.open(mods_tmp, "w"))
  f1:write(to_json(mods_list))
  f1:close()

  local f2 = assert(io.open(sum_tmp, "w"))
  f2:write(to_json(summary))
  f2:close()

  local cmd = "python3 - " .. shell_quote(registry_path) .. " " .. shell_quote(last_run_path) .. " " .. shell_quote(mods_tmp) .. " " .. shell_quote(sum_tmp) .. " <<'PY'\n"
    .. "import json,sys\n"
    .. "from datetime import datetime, timezone\n"
    .. "reg_path,last_run_path,mods_path,sum_path=sys.argv[1:5]\n"
    .. "with open(reg_path,'r',encoding='utf-8') as f:data=json.load(f)\n"
    .. "with open(mods_path,'r',encoding='utf-8') as f:newmods=json.load(f)\n"
    .. "with open(sum_path,'r',encoding='utf-8') as f:summary=json.load(f)\n"
    .. "ov=data.setdefault('overrides',{})\n"
    .. "if not isinstance(ov,dict):\n"
    .. "  ov={}\n"
    .. "  data['overrides']=ov\n"
    .. "ov.setdefault('requireAliases',{})\n"
    .. "try:\n"
    .. "  with open(last_run_path,'r',encoding='utf-8') as f:last_run=json.load(f)\n"
    .. "  if not isinstance(last_run,dict):\n"
    .. "    last_run={}\n"
    .. "except Exception:\n"
    .. "  last_run={}\n"
    .. "data['mods']=newmods\n"
    .. "data['generatedAt']=datetime.now(timezone.utc).isoformat()\n"
    .. "res=data.setdefault('resolution',{})\n"
    .. "if isinstance(res,dict):\n"
    .. "  res.pop('lastRun',None)\n"
    .. "last_run['status']=summary.get('status')\n"
    .. "last_run['message']=summary.get('message')\n"
    .. "last_run['importedWorkshopIds']=summary.get('importedWorkshopIds',[])\n"
    .. "last_run['importedModIds']=summary.get('importedModIds',[])\n"
    .. "last_run['missingModIds']=summary.get('missingModIds',[])\n"
    .. "last_run['missingModIdsUnknownWorkshop']=summary.get('missingModIdsUnknownWorkshop',[])\n"
    .. "last_run['cycles']=summary.get('cycles',[])\n"
    .. "last_run['enabledWorkshopIds']=summary.get('enabledWorkshopIds',[])\n"
    .. "last_run['enabledModIdsOrdered']=summary.get('enabledModIdsOrdered',[])\n"
    .. "last_run['resolverEngine']='lua'\n"
    .. "last_run['resolverHints']=summary.get('resolverHints',{})\n"
    .. "for k,v in {\n"
    .. "  'missingWorkshopIds':[],\n"
    .. "  'installPlannedWorkshopIds':[],\n"
    .. "  'installCompletedWorkshopIds':[],\n"
    .. "  'installFailedWorkshopIds':[],\n"
    .. "  'conflicts':[]\n"
    .. "}.items():\n"
    .. "  last_run.setdefault(k,v)\n"
    .. "with open(reg_path,'w',encoding='utf-8') as f:json.dump(data,f,indent=2,sort_keys=False);f.write('\\n')\n"
    .. "with open(last_run_path,'w',encoding='utf-8') as f:json.dump(last_run,f,indent=2,sort_keys=False);f.write('\\n')\n"
    .. "PY"

  local ok = os.execute(cmd)
  os.remove(mods_tmp)
  os.remove(sum_tmp)
  if ok == true or ok == 0 then return true end
  return false
end

local function parse_args(argv)
  local opts = {
    registry = nil,
    last_run_file = nil,
    mods_yml = nil,
    workshop_root = nil,
    workshop_appid = "108600",
    write = false,
    runtime_probe = false,
    probe_umbrella_root = "",
    probe_max_items = 0,
    probe_max_files = 0,
    probe_report_file = "",
    probe_json_report_file = "",
    probe_retry_from_json = "",
    probe_no_registry_update = false,
  }

  local i = 1
  while i <= #argv do
    local a = argv[i]
    if a == "--registry" then
      i = i + 1
      opts.registry = argv[i]
    elseif a == "--last-run-file" then
      i = i + 1
      opts.last_run_file = argv[i]
    elseif a == "--mods-yml" then
      i = i + 1
      opts.mods_yml = argv[i]
    elseif a == "--workshop-root" then
      i = i + 1
      opts.workshop_root = argv[i]
    elseif a == "--workshop-appid" then
      i = i + 1
      opts.workshop_appid = argv[i] or "108600"
    elseif a == "--write" then
      opts.write = true
    elseif a == "--runtime-probe" then
      opts.runtime_probe = true
    elseif a == "--probe-umbrella-root" then
      i = i + 1
      opts.probe_umbrella_root = argv[i] or ""
    elseif a == "--probe-max-items" then
      i = i + 1
      opts.probe_max_items = tonumber(argv[i] or "0") or 0
    elseif a == "--probe-max-files" then
      i = i + 1
      opts.probe_max_files = tonumber(argv[i] or "0") or 0
    elseif a == "--probe-report-file" then
      i = i + 1
      opts.probe_report_file = argv[i] or ""
    elseif a == "--probe-json-report-file" then
      i = i + 1
      opts.probe_json_report_file = argv[i] or ""
    elseif a == "--probe-retry-from-json" then
      i = i + 1
      opts.probe_retry_from_json = argv[i] or ""
    elseif a == "--probe-no-registry-update" then
      opts.probe_no_registry_update = true
    elseif a == "-h" or a == "--help" then
      print("Usage: lua init/resolver.lua --registry <path> [--last-run-file <path>] --mods-yml <path> [--workshop-root <path>] [--workshop-appid 108600] [--runtime-probe] [--probe-*-options] [--write]")
      os.exit(0)
    else
      stderr("Unknown arg: " .. tostring(a))
      os.exit(2)
    end
    i = i + 1
  end

  if not opts.registry or not opts.mods_yml then
    stderr("Usage: lua init/resolver.lua --registry <path> [--last-run-file <path>] --mods-yml <path> [--workshop-root <path>] [--workshop-appid 108600] [--runtime-probe] [--probe-*-options] [--write]")
    os.exit(2)
  end
  if not is_file(opts.registry) then
    stderr("ERROR: registry not found: " .. tostring(opts.registry))
    os.exit(2)
  end
  if opts.workshop_root and opts.workshop_root ~= "" and not is_dir(opts.workshop_root) then
    stderr("ERROR: workshop root not found: " .. tostring(opts.workshop_root))
    os.exit(2)
  end

  if opts.runtime_probe and (not opts.workshop_root or trim(opts.workshop_root) == "") then
    stderr("ERROR: --runtime-probe requires --workshop-root")
    os.exit(2)
  end

  if not opts.last_run_file or trim(opts.last_run_file) == "" then
    opts.last_run_file = default_last_run_path(opts.registry)
  end

  return opts
end

local function main()
  local opts = parse_args(arg)

  local reg, rerr = load_registry_entries(opts.registry)
  if not reg then
    stderr("ERROR: " .. tostring(rerr))
    os.exit(2)
  end

  local blocks = parse_mods_blocks(opts.mods_yml)
  local import_result = apply_import_blocks(reg, blocks)

  local scan_by_wid = {}
  if opts.workshop_root and opts.workshop_root ~= "" then
    scan_by_wid = enrich_with_scan(reg, opts.workshop_root)
  end

  apply_explicit_selection(reg, import_result.explicit_selection)

  local resolution = resolve_order(reg, scan_by_wid)
  reorder_registry(reg, resolution)

  local probe_result = nil
  if opts.runtime_probe then
    probe_result = run_runtime_probe(reg, opts)
    if (probe_result.counts.registry_auto_added_count or 0) > 0 then
      resolution = resolve_order(reg, scan_by_wid)
      reorder_registry(reg, resolution)
    end
  end

  local missing_ids = sorted_keys(resolution.missing)
  local enabled_workshops = {}
  local enabled_workshop_seen = {}
  for _, mid in ipairs(resolution.ordered_mods) do
    local wid = resolution.mod_to_wid[mid]
    if wid and not enabled_workshop_seen[wid] then
      enabled_workshop_seen[wid] = true
      enabled_workshops[#enabled_workshops + 1] = wid
    end
  end

  local library_mods = {}
  local provider_mods = {}
  for _, mid in ipairs(resolution.ordered_mods) do
    local role = resolution.role[mid] or {}
    if role.library then library_mods[#library_mods + 1] = mid end
    if role.resource_provider then provider_mods[#provider_mods + 1] = mid end
  end

  local status = (#resolution.cycles > 0) and "error" or "ok"
  if #resolution.cycles > 0 then
    status = "error"
  elseif #missing_ids > 0 then
    status = "warn"
  else
    status = "ok"
  end
  local message = "Resolved successfully (lua)"
  if #resolution.cycles > 0 then
    message = "Dependency cycles detected"
  elseif #missing_ids > 0 then
    message = "Resolved with missing requires"
  end

  local summary = {
    status = status,
    message = message,
    importedWorkshopIds = import_result.imported_workshops,
    importedModIds = import_result.imported_mods,
    missingModIds = missing_ids,
    missingModIdsUnknownWorkshop = missing_ids,
    cycles = resolution.cycles,
    enabledWorkshopIds = enabled_workshops,
    enabledModIdsOrdered = resolution.ordered_mods,
    resolverHints = {
      duplicateModProviders = resolution.duplicates,
      libraryMods = library_mods,
      resourceProviderMods = provider_mods,
    },
  }

  if probe_result then
    summary.runtimeProbe = {
      orderAnomalies = probe_result.issues.order_anomalies or {},
      dependencyPresenceSummary = probe_result.issues.dependency_presence_summary or {},
      registryAutoAdded = probe_result.counts.registry_auto_added or {},
      registryAutoAddedCount = probe_result.counts.registry_auto_added_count or 0,
    }
  end

  print("[resolver.lua] imported workshop IDs: " .. tostring(#import_result.imported_workshops))
  print("[resolver.lua] enabled mods ordered: " .. tostring(#resolution.ordered_mods))
  print("[resolver.lua] library mods detected: " .. tostring(#library_mods))
  print("[resolver.lua] resource providers detected: " .. tostring(#provider_mods))
  print("[resolver.lua] missing requires: " .. tostring(#missing_ids))
  print("[resolver.lua] dependency cycles: " .. tostring(#resolution.cycles))
  if probe_result then
    print("[resolver.lua] runtime probe anomalies: " .. tostring(#(probe_result.issues.order_anomalies or {})))
    print("[resolver.lua] runtime probe autofixed deps: " .. tostring(probe_result.counts.registry_auto_added_count or 0))
  end

  if opts.write then
    local mods_list = build_compact_mods_list(reg)
    local ok = write_registry(opts.registry, opts.last_run_file, mods_list, summary)
    if not ok then
      stderr("ERROR: failed to write registry")
      os.exit(2)
    end

    local okm, merr = write_clean_mods_yml(opts.mods_yml)
    if not okm then
      stderr("ERROR: failed to write import-mods.yml: " .. tostring(merr))
      os.exit(2)
    end
    print("[resolver.lua] wrote registry, last-run metadata, and cleaned import-mods.yml")
  else
    print("[resolver.lua] dry run only (--write not set)")
  end

  if #resolution.cycles > 0 then
    os.exit(1)
  end
  os.exit(0)
end

main()
