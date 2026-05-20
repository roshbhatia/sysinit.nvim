-- amp adapter: hybrid (bridge + spawned pane).
--   amp.nvim runs a websocket bridge inside nvim (opts.auto_start = true).
--   The CLI we spawn in the pane reads the lockfile amp.nvim writes and
--   auto-connects via --ide (default on). So send() can still use
--   amp.message.send_message to relay context-aware messages into the
--   connected CLI, while the pane gives the user a real UI to interact
--   with and lets CLI flags actually apply at spawn time.
--
-- NOTE: amp resume is a SUBCOMMAND (`amp threads continue`), not a flag,
-- so this adapter can't use _shared.raw_cli_adapter. The `thread` option
-- (cli=false) flips the cmd prefix to `amp threads continue`, letting
-- amp's own picker fire on launch.
--
-- CAVEAT: If the user also runs amp externally, two clients will connect
-- to the same bridge. amp.nvim's multi-client behavior is undocumented;
-- recommend picking one path (harness OR external).

local lifecycle = require("harness.lifecycle")

local lc
local lc_signature

local function build_amp_parts()
  local sel = require("harness.options").get_selected("amp")
  local parts = { "amp" }
  if sel.thread then
    table.insert(parts, "threads")
    table.insert(parts, "continue")
  end
  if sel.dangerous then
    table.insert(parts, "--dangerously-allow-all")
  end
  if sel.mode and sel.mode ~= "" then
    table.insert(parts, "--mode")
    table.insert(parts, sel.mode)
  end
  if sel.visibility and sel.visibility ~= "" then
    table.insert(parts, "--visibility")
    table.insert(parts, sel.visibility)
  end
  if sel.effort and sel.effort ~= "" then
    table.insert(parts, "--effort")
    table.insert(parts, sel.effort)
  end
  return parts
end

local function build_cmd_string()
  local parts = build_amp_parts()
  if #parts == 1 then
    return parts[1]
  end
  local rest = {}
  for i = 2, #parts do
    rest[i - 1] = vim.fn.shellescape(parts[i])
  end
  return parts[1] .. " " .. table.concat(rest, " ")
end

local function ensure_lifecycle()
  local cmd = build_cmd_string()
  if not lc or lc_signature ~= cmd then
    if lc and lc.kill then
      pcall(lc.kill)
    end
    lc = lifecycle.build(cmd, { name = "amp", percent = 0.4 })
    lc_signature = cmd
  end
  return lc
end

local function amp_message_ok()
  return pcall(require, "amp.message")
end

return {
  name = "amp",
  label = "󰫤  Amp",
  options_schema = {
    { name = "dangerous", flag = "--dangerously-allow-all", kind = "toggle" },
    {
      name = "mode",
      flag = "--mode",
      kind = "value",
      prompt = "deep|free|large|rush|smart",
    },
    {
      name = "visibility",
      flag = "--visibility",
      kind = "value",
      prompt = "private|public|workspace|group",
    },
    {
      name = "effort",
      flag = "--effort",
      kind = "value",
      prompt = "Effort (mode-dependent: e.g. minimal|low|medium|high|xhigh)",
    },
    {
      name = "thread",
      flag = "threads continue",
      label = "resume via amp picker",
      kind = "toggle",
      cli = false,
    },
    {
      name = "submit",
      flag = "submit",
      label = "auto-submit on send",
      kind = "toggle",
      cli = false,
    },
  },
  available = function()
    return amp_message_ok() and vim.fn.executable("amp") == 1
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
  send = function(text, opts)
    opts = opts or {}
    local ok, msg = pcall(require, "amp.message")
    if not ok then
      vim.notify("amp: amp.message module not loadable", vim.log.levels.WARN)
      return
    end
    local sel = require("harness.options").get_selected("amp")
    local submit
    if sel.submit ~= nil then
      submit = sel.submit and true or false
    else
      submit = opts.submit ~= false
    end
    local fn = submit and msg.send_message or msg.send_to_prompt
    local sent_ok, sent = pcall(fn, text)
    if not sent_ok then
      vim.notify("amp: send error: " .. tostring(sent), vim.log.levels.WARN)
      return
    end
    if sent == false then
      vim.notify("amp: bridge has no connected client — toggle amp first (<leader>jj → amp)", vim.log.levels.WARN)
      return
    end
    vim.notify(string.format("amp: %s %d chars", submit and "submitted" or "appended", #text), vim.log.levels.INFO)
  end,
  kill = function()
    if lc then
      lc.kill()
      lc = nil
      lc_signature = nil
    end
  end,
}
