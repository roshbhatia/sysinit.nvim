local function amp_message_ok()
  return pcall(require, "amp.message")
end

local function warn_no_ui()
  vim.notify("amp: no embedded UI to focus — amp runs out-of-process", vim.log.levels.WARN)
end

return {
  name = "amp",
  label = "Amp",
  available = function()
    return amp_message_ok() and vim.fn.executable("amp") == 1
  end,
  toggle = warn_no_ui,
  focus = warn_no_ui,
  is_visible = function()
    return false
  end,
  send = function(text, _opts)
    local ok, msg = pcall(require, "amp.message")
    if not ok then
      vim.notify("amp: amp.message module not loadable", vim.log.levels.WARN)
      return
    end
    local sent_ok, sent = pcall(msg.send_message, text)
    if not sent_ok then
      vim.notify("amp: send_message error: " .. tostring(sent), vim.log.levels.WARN)
      return
    end
    if sent == false then
      vim.notify("amp: bridge not connected — start with :AmpStart or set auto_start=true", vim.log.levels.WARN)
      return
    end
    vim.notify("amp: sent " .. #text .. " chars", vim.log.levels.INFO)
  end,
  kill = function() end,
}
