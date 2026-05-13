-- amp.nvim is an IDE bridge (LSP-ish), not a terminal manager. The amp CLI
-- is spawned externally by the user; this adapter only talks to it via
-- amp.message. Two send modes are available:
--   submit=true  → amp.message.send_message    (submits a userSentMessage)
--   submit=false → amp.message.send_to_prompt  (appends to amp's input box)
-- The `submit` option below sets the default; the harness ask flow's
-- per-call submit param (currently false everywhere) overrides it.

local function amp_message_ok()
  return pcall(require, "amp.message")
end

local function warn_no_ui()
  vim.notify("amp: no embedded UI to focus — amp runs out-of-process", vim.log.levels.WARN)
end

return {
  name = "amp",
  label = "Amp",
  options_schema = {
    { name = "submit", flag = "submit", label = "auto-submit on send", kind = "toggle", cli = false },
  },
  available = function()
    return amp_message_ok() and vim.fn.executable("amp") == 1
  end,
  toggle = warn_no_ui,
  focus = warn_no_ui,
  is_visible = function()
    return false
  end,
  send = function(text, opts)
    opts = opts or {}
    local ok, msg = pcall(require, "amp.message")
    if not ok then
      vim.notify("amp: amp.message module not loadable", vim.log.levels.WARN)
      return
    end
    -- Per-agent option overrides the api.send caller's submit flag.
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
      vim.notify("amp: bridge not connected — start with :AmpStart", vim.log.levels.WARN)
      return
    end
    vim.notify(
      string.format("amp: %s %d chars", submit and "submitted" or "appended", #text),
      vim.log.levels.INFO
    )
  end,
  kill = function() end,
}
