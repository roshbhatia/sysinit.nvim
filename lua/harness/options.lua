local M = {}

---@class harness.OptionDef
---@field name      string   -- key used in state table (e.g. "dangerous")
---@field flag      string   -- CLI flag emitted (e.g. "--dangerously-skip-permissions")
---@field kind      string   -- "toggle" | "value"
---@field default?  any
---@field prompt?   string   -- prompt label for kind="value"
---@field label?    string   -- display label in picker (defaults to flag)

local STATE_DIR = vim.fn.stdpath("state") .. "/harness"
local STATE_FILE = STATE_DIR .. "/options.json"

---@type table<string, table<string, any>>  agent_name → { opt_name = value }
local state = {}
local loaded = false

local function load()
  if loaded then return end
  loaded = true
  local fd = io.open(STATE_FILE, "r")
  if not fd then return end
  local raw = fd:read("*a")
  fd:close()
  if not raw or raw == "" then return end
  local ok, data = pcall(vim.json.decode, raw)
  if ok and type(data) == "table" then
    state = data
  end
end

local function save()
  vim.fn.mkdir(STATE_DIR, "p")
  local ok, encoded = pcall(vim.json.encode, state)
  if not ok then return end
  local tmp = STATE_FILE .. ".tmp"
  local fd = io.open(tmp, "w")
  if not fd then return end
  fd:write(encoded)
  fd:close()
  pcall(vim.uv.fs_rename, tmp, STATE_FILE)
end

---@param agent_name string
---@return harness.OptionDef[]|nil
function M.get_schema(agent_name)
  local ok, adapter = pcall(require, "harness.adapters." .. agent_name)
  if not ok then
    return nil
  end
  return adapter.options_schema
end

---@param agent_name string
---@return table<string, any>
function M.get_selected(agent_name)
  load()
  if not state[agent_name] then
    state[agent_name] = {}
    local schema = M.get_schema(agent_name)
    if schema then
      for _, opt in ipairs(schema) do
        if opt.default ~= nil then
          state[agent_name][opt.name] = opt.default
        end
      end
    end
    save()
  end
  return state[agent_name]
end

---@param agent_name string
---@param opt_name string
---@param value any
function M.set(agent_name, opt_name, value)
  local sel = M.get_selected(agent_name)
  sel[opt_name] = value
  save()
end

---@param agent_name string
---@param opt_name string
function M.toggle(agent_name, opt_name)
  local sel = M.get_selected(agent_name)
  sel[opt_name] = not sel[opt_name]
  save()
end

---@param agent_name string
function M.reset(agent_name)
  load()
  state[agent_name] = nil
  save()
end

---@param agent_name string
---@return string[]
function M.build_args(agent_name)
  local schema = M.get_schema(agent_name)
  if not schema then
    return {}
  end
  local sel = M.get_selected(agent_name)
  local args = {}
  for _, opt in ipairs(schema) do
    if opt.cli ~= false then
      local v = sel[opt.name]
      if opt.kind == "toggle" then
        if v then
          table.insert(args, opt.flag)
        end
      elseif opt.kind == "value" then
        if v and v ~= "" then
          table.insert(args, opt.flag)
          table.insert(args, tostring(v))
        end
      end
    end
  end
  return args
end

---@param agent_name string
---@return string
function M.summary(agent_name)
  local schema = M.get_schema(agent_name)
  if not schema then
    return ""
  end
  local sel = M.get_selected(agent_name)
  local parts = {}
  for _, opt in ipairs(schema) do
    local v = sel[opt.name]
    if opt.kind == "toggle" and v then
      table.insert(parts, opt.label or opt.flag)
    elseif opt.kind == "value" and v and v ~= "" then
      table.insert(parts, (opt.label or opt.flag) .. "=" .. tostring(v))
    end
  end
  return table.concat(parts, " ")
end

---@param agent_name string
---@param on_close? fun()
function M.configure(agent_name, on_close)
  local schema = M.get_schema(agent_name)
  if not schema or #schema == 0 then
    vim.notify("harness: " .. agent_name .. " has no configurable options", vim.log.levels.INFO)
    if on_close then on_close() end
    return
  end

  local sel = M.get_selected(agent_name)

  local function format_item(opt)
    local cur = sel[opt.name]
    local right
    if opt.kind == "toggle" then
      right = cur and "[x]" or "[ ]"
    else
      right = cur and ("= " .. tostring(cur)) or "(unset)"
    end
    local display = opt.label or opt.flag
    return string.format("%-12s  %-40s  %s", right, display, opt.kind)
  end

  local ok_snacks, snacks = pcall(require, "snacks")
  if not (ok_snacks and snacks.picker) then
    vim.notify("harness: snacks.picker unavailable", vim.log.levels.WARN)
    if on_close then on_close() end
    return
  end

  local items = {}
  for i, opt in ipairs(schema) do
    table.insert(items, { idx = i, opt = opt, text = format_item(opt) })
  end
  -- Sentinel "submit" item so the user has an explicit way to close the
  -- options picker via <CR>. Esc cancels with the same effect.
  table.insert(items, { idx = -1, opt = nil, text = string.format("%-12s  %s", "", "→ Continue (submit options)") })

  local function reopen()
    M.configure(agent_name, on_close)
  end

  snacks.picker.pick({
    source = "harness_options_" .. agent_name,
    items = items,
    format = function(item) return { { item.text, "Normal" } } end,
    title = "Options — " .. agent_name,
    layout = { preset = "select" },
    confirm = function(picker, item)
      picker:close()
      if not item or not item.opt then
        if on_close then on_close() end
        return
      end
      local opt = item.opt
      if opt.kind == "toggle" then
        M.toggle(agent_name, opt.name)
        vim.schedule(reopen)
        return
      end
      if opt.picker_source then
        require("harness.sessions").list(opt.picker_source, function(value)
          if value ~= nil then
            M.set(agent_name, opt.name, value)
          end
          vim.schedule(reopen)
        end)
        return
      end
      vim.ui.input({
        prompt = (opt.prompt or opt.flag) .. ": ",
        default = sel[opt.name] and tostring(sel[opt.name]) or "",
      }, function(value)
        if value ~= nil then
          M.set(agent_name, opt.name, value ~= "" and value or nil)
        end
        vim.schedule(reopen)
      end)
    end,
    actions = {
      reset_all = function(picker)
        picker:close()
        M.reset(agent_name)
        vim.schedule(reopen)
      end,
    },
    win = {
      input = {
        keys = {
          ["<c-r>"] = { "reset_all", mode = { "i", "n" } },
        },
      },
    },
  })
end

return M
