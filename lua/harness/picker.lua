---@mod harness.picker Agent picker UI
---@brief [[
--- Toggle-if-active semantics: if an agent is active and visible → hide;
--- active but not visible → focus; otherwise open vim.ui.select over the
--- list of available adapters and activate the chosen one.
---@brief ]]

local M = {}

local function active_adapter()
  local session = require("harness.session")
  local registry = require("harness.registry")
  local name = session.get_active()
  if not name then
    return nil
  end
  return registry.get_by_name(name)
end

function M.pick_agent()
  local session = require("harness.session")
  local registry = require("harness.registry")

  local active = active_adapter()
  if active then
    local ok, visible = pcall(active.is_visible)
    if ok and visible then
      pcall(active.toggle)
      return
    end
    -- Active but pane is gone; try to focus (re-open path inside adapter).
    local fok = pcall(active.focus)
    if fok then
      return
    end
  end

  local available = registry.get_all_available()
  if #available == 0 then
    vim.notify("Harness: no agents available on PATH", vim.log.levels.WARN)
    return
  end

  vim.ui.select(available, {
    prompt = "Select agent:",
    format_item = function(adapter)
      local current = session.get_active()
      local suffix = adapter.name == current and " (active)" or ""
      return adapter.label .. suffix
    end,
  }, function(adapter)
    if not adapter then
      return
    end
    session.set_active(adapter.name)
    pcall(adapter.toggle)
  end)
end

function M.kill_active()
  local session = require("harness.session")
  local adapter = active_adapter()
  if adapter and adapter.kill then
    pcall(adapter.kill)
  elseif adapter then
    pcall(adapter.toggle) -- best-effort hide
  end
  session.clear_active()
end

function M.kill_and_pick()
  M.kill_active()
  M.pick_agent()
end

return M
