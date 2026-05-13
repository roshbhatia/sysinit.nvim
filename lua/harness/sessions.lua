local M = {}

local function decode_json(raw)
  if not raw or raw == "" then return nil end
  local ok, data = pcall(vim.json.decode, raw)
  if not ok then return nil end
  return data
end

-- Per-source listers. Each returns { { value, label }, ... } where `value`
-- is what gets templated into the option (e.g. session id) and `label` is
-- what's shown in the picker.
local LISTERS = {}

function LISTERS.crush()
  local res = vim.fn.system({ "crush", "session", "list", "--json" })
  if vim.v.shell_error ~= 0 then return nil end
  local data = decode_json(res)
  if type(data) ~= "table" then return nil end
  local items = {}
  for _, s in ipairs(data) do
    local title = s.title or s.name or s.id or "?"
    table.insert(items, {
      value = s.id,
      label = string.format("%s  (%s)", title, tostring(s.id):sub(1, 8)),
    })
  end
  return items
end

function LISTERS.goose()
  local res = vim.fn.system({ "goose", "session", "list", "-f", "json" })
  if vim.v.shell_error ~= 0 then return nil end
  local data = decode_json(res)
  if type(data) ~= "table" then return nil end
  local items = {}
  for _, s in ipairs(data) do
    local name = s.name or s.id or "?"
    local desc = s.description or s.summary or ""
    table.insert(items, {
      value = name,
      label = desc ~= "" and (name .. " — " .. desc) or name,
    })
  end
  return items
end

---@param source string
---@param on_select fun(value: string|nil)
function M.list(source, on_select)
  local lister = LISTERS[source]
  if not lister then
    vim.notify("Harness: no session lister for " .. source, vim.log.levels.WARN)
    on_select(nil)
    return
  end

  local items = lister()
  if not items or #items == 0 then
    vim.notify("Harness: no sessions found for " .. source, vim.log.levels.WARN)
    on_select(nil)
    return
  end

  local ok, snacks = pcall(require, "snacks")
  if not (ok and snacks.picker) then
    vim.ui.select(items, {
      prompt = "Resume " .. source .. " session:",
      format_item = function(item) return item.label end,
    }, function(item)
      on_select(item and item.value or nil)
    end)
    return
  end

  snacks.picker.pick({
    source = "harness_sessions_" .. source,
    items = items,
    format = function(item) return { { item.label, "Normal" } } end,
    title = "Resume — " .. source,
    layout = { preset = "select" },
    confirm = function(picker, item)
      picker:close()
      on_select(item and item.value or nil)
    end,
  })
end

return M
