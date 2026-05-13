local M = {}

---@class harness.OptionDef
---@field name      string   -- key used in state table (e.g. "dangerous")
---@field flag      string   -- CLI flag emitted (e.g. "--dangerously-skip-permissions")
---@field kind      string   -- "toggle" | "value"
---@field default?  any
---@field prompt?   string   -- prompt label for kind="value"
---@field label?    string   -- display label in picker (defaults to flag)

---@type table<string, table<string, any>>  agent_name → { opt_name = value }
local state = {}

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
  end
  return state[agent_name]
end

---@param agent_name string
---@param opt_name string
---@param value any
function M.set(agent_name, opt_name, value)
  local sel = M.get_selected(agent_name)
  sel[opt_name] = value
end

---@param agent_name string
---@param opt_name string
function M.toggle(agent_name, opt_name)
  local sel = M.get_selected(agent_name)
  sel[opt_name] = not sel[opt_name]
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
  return args
end

---@param agent_name string
---@return string
function M.summary(agent_name)
  local args = M.build_args(agent_name)
  if #args == 0 then
    return ""
  end
  return table.concat(args, " ")
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
    return string.format("%-12s  %-40s  %s", right, opt.flag, opt.kind)
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
      if not item then
        if on_close then on_close() end
        return
      end
      local opt = item.opt
      if opt.kind == "toggle" then
        M.toggle(agent_name, opt.name)
        vim.schedule(reopen)
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
        state[agent_name] = nil
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
