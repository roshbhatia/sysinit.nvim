---@mod harness.adapters._shared Adapter contract + raw-CLI factory
---@brief [[
--- Adapter shape:
---   {
---     name        : string  -- unique identifier (also used in vim.g.harness_active)
---     label       : string  -- display name
---     available() : boolean -- whether this adapter is usable right now
---     toggle()             -- show/hide the pane (no-op for bridge-only adapters)
---     focus()              -- focus the pane (no-op for bridge-only adapters)
---     send(text, {submit?: boolean})
---     is_visible() : boolean
---     kill()               -- optional; falls back to toggle if absent
---   }
---@brief ]]

local M = {}

local lifecycle = require("harness.lifecycle")

---@param def { name: string, label: string, cmd: string, args?: string[], percent?: number, side?: "left"|"right" }
---@return table adapter
function M.raw_cli_adapter(def)
  local cmd_string = def.cmd
  if def.args and #def.args > 0 then
    local escaped = {}
    for i, a in ipairs(def.args) do
      escaped[i] = vim.fn.shellescape(a)
    end
    cmd_string = def.cmd .. " " .. table.concat(escaped, " ")
  end

  local lc -- lazy-built so we don't spawn anything at module load

  local function ensure()
    if not lc then
      lc = lifecycle.build(cmd_string, {
        name = def.name,
        percent = def.percent,
        side = def.side,
      })
    end
    return lc
  end

  return {
    name = def.name,
    label = def.label,
    available = function()
      return vim.fn.executable(def.cmd) == 1
    end,
    toggle = function()
      ensure().toggle()
    end,
    focus = function()
      ensure().focus()
    end,
    is_visible = function()
      if not lc then
        return false
      end
      return lc.is_visible()
    end,
    send = function(text, opts)
      ensure().send(text, opts or { submit = true })
    end,
    kill = function()
      if lc then
        lc.kill()
      end
    end,
  }
end

return M
