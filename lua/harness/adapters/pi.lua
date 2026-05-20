local lifecycle = require("harness.lifecycle")

local lc

local function ensure_lifecycle()
  if not lc then
    lc = lifecycle.build("pi", { name = "pi", percent = 0.4 })
  end
  return lc
end

-- pi.run reads pi.config at runtime to assemble the cmd. We bypass that
-- by passing an explicit cmd built from the harness options.
local function build_pi_cmd()
  local sel = require("harness.options").get_selected("pi")
  local cmd = { "pi", "--mode", "rpc", "--no-session" }
  if sel.no_tools then
    table.insert(cmd, "--no-tools")
  end
  if sel.fast then
    table.insert(cmd, "--fast")
  end
  if sel.plan then
    table.insert(cmd, "--plan")
  end
  if sel.verbose then
    table.insert(cmd, "--verbose")
  end
  if sel["continue"] then
    table.insert(cmd, "--continue")
  end
  if sel.resume then
    table.insert(cmd, "--resume")
  end
  if sel.thinking and sel.thinking ~= "" then
    table.insert(cmd, "--thinking")
    table.insert(cmd, sel.thinking)
  end
  if sel.provider and sel.provider ~= "" then
    table.insert(cmd, "--provider")
    table.insert(cmd, sel.provider)
  end
  if sel.model and sel.model ~= "" then
    table.insert(cmd, "--model")
    table.insert(cmd, sel.model)
  end
  return cmd
end

return {
  name = "pi",
  label = "󰏿  Pi",
  options_schema = {
    { name = "no_tools", flag = "--no-tools", kind = "toggle" },
    { name = "fast", flag = "--fast", kind = "toggle" },
    { name = "plan", flag = "--plan", kind = "toggle" },
    { name = "verbose", flag = "--verbose", kind = "toggle" },
    { name = "continue", flag = "--continue", kind = "toggle" },
    { name = "resume", flag = "--resume", kind = "toggle" },
    { name = "thinking", flag = "--thinking", kind = "value", prompt = "off|minimal|low|medium|high|xhigh" },
    { name = "provider", flag = "--provider", kind = "value", prompt = "Provider (e.g. anthropic, openai, google)" },
    { name = "model", flag = "--model", kind = "value", prompt = "Model pattern (e.g. anthropic/sonnet)" },
  },
  available = function()
    return vim.fn.executable("pi") == 1
  end,
  toggle = function()
    ensure_lifecycle().toggle()
  end,
  focus = function()
    ensure_lifecycle().focus()
  end,
  is_visible = function()
    if not lc then
      return false
    end
    return lc.is_visible()
  end,
  send = function(text, _opts)
    local ok, pi = pcall(require, "pi")
    if not ok then
      vim.notify("pi: plugin not loadable", vim.log.levels.WARN)
      return
    end
    pi.run({
      message = text,
      bufnr = vim.api.nvim_get_current_buf(),
      cmd = build_pi_cmd(),
    })
  end,
  kill = function()
    if lc then
      lc.kill()
    end
  end,
}
