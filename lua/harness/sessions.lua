local M = {}

local function decode_json(raw)
  if not raw or raw == "" then return nil end
  local ok, data = pcall(vim.json.decode, raw)
  if not ok then return nil end
  return data
end

-- ---------------------------------------------------------------------------
-- Per-agent session listers
--
-- Each lister returns { items, apply } where:
--   items = { { id, label, ... }, ... }
--   apply(item) = sets the relevant option(s) on harness.options
-- ---------------------------------------------------------------------------

local LISTERS = {}

function LISTERS.crush()
  local res = vim.fn.system({ "crush", "session", "list", "--json" })
  if vim.v.shell_error ~= 0 then return nil end
  local data = decode_json(res)
  if type(data) ~= "table" then return nil end
  local items = {}
  for _, s in ipairs(data) do
    local label = s.title or s.name or s.id or "?"
    table.insert(items, { id = s.id, label = string.format("%s  (%s)", label, tostring(s.id):sub(1, 8)) })
  end
  return {
    items = items,
    apply = function(item)
      require("harness.options").set("crush", "session", item.id)
    end,
  }
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
    table.insert(items, { id = name, label = desc ~= "" and (name .. " — " .. desc) or name })
  end
  return {
    items = items,
    apply = function(item)
      local options = require("harness.options")
      options.set("goose", "resume", true)
      options.set("goose", "name", item.id)
    end,
  }
end

-- ---------------------------------------------------------------------------
-- Fallback: agents whose CLI doesn't expose a list command — flip the
-- "resume" toggle so the agent opens its own picker on next launch.
-- ---------------------------------------------------------------------------

local DELEGATING = {
  claudecode = "resume",
  codex      = nil,        -- codex resume is a subcommand swap; not wired yet
  copilot    = "resume",
  cursor     = "resume",
  gemini     = "resume",   -- gemini -r takes "latest" etc; we set "latest" by default
}

local function delegate_to_agent(agent_name)
  local options = require("harness.options")
  local opt = DELEGATING[agent_name]
  if not opt then
    vim.notify("Harness: " .. agent_name .. " has no session picker", vim.log.levels.WARN)
    return
  end
  -- For gemini the resume flag needs a value; default to "latest" if unset.
  if agent_name == "gemini" then
    local sel = options.get_selected("gemini")
    if not sel.resume or sel.resume == "" or sel.resume == true then
      options.set("gemini", "resume", "latest")
    end
  else
    options.set(agent_name, opt, true)
  end
  vim.notify(
    "Harness: " .. agent_name .. " — resume flag set; agent will show its own picker on launch",
    vim.log.levels.INFO
  )
end

-- ---------------------------------------------------------------------------
-- Public: open a session picker for *agent_name*
-- ---------------------------------------------------------------------------

---@param agent_name string
---@param on_done?   fun()
function M.pick_for(agent_name, on_done)
  on_done = on_done or function() end

  local lister = LISTERS[agent_name]
  if not lister then
    delegate_to_agent(agent_name)
    on_done()
    return
  end

  local result = lister()
  if not result or #result.items == 0 then
    vim.notify("Harness: no sessions found for " .. agent_name, vim.log.levels.WARN)
    on_done()
    return
  end

  local ok, snacks = pcall(require, "snacks")
  if not (ok and snacks.picker) then
    vim.ui.select(result.items, {
      prompt = "Resume " .. agent_name .. " session:",
      format_item = function(item) return item.label end,
    }, function(item)
      if item then result.apply(item) end
      on_done()
    end)
    return
  end

  snacks.picker.pick({
    source = "harness_sessions_" .. agent_name,
    items = result.items,
    format = function(item) return { { item.label, "Normal" } } end,
    title = "Resume — " .. agent_name,
    layout = { preset = "select" },
    confirm = function(picker, item)
      picker:close()
      if item then result.apply(item) end
      on_done()
    end,
  })
end

return M
