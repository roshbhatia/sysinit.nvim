-- pi.nvim — minimal AI coding agent integration (badlogic/pi-mono).
--
-- pi.nvim itself is fire-and-forget: :PiAsk sends buffer+prompt as context,
-- pi edits files on disk, plugin reloads buffers. No embedded terminal.
--
-- For interactive REPL mode we keep a separate <leader>it toggle that opens
-- pi (without args) in a wezterm pane split, falling back to snacks.terminal
-- when not in wezterm — same pattern as claudecode/opencode.
local function open_interactive_pi()
  local choice = vim.g.pi_provider or "auto"
  if choice == "auto" then
    local in_wezterm = vim.env.WEZTERM_PANE ~= nil and vim.fn.executable("wezterm") == 1
    choice = in_wezterm and "wezterm" or "snacks"
  end

  if choice == "wezterm" then
    local ok, wezterm = pcall(require, "utils.wezterm_terminal")
    if ok then
      local server = wezterm.build_server_callbacks("pi", { name = "pi", percent = 0.4 })
      vim.b._pi_server = server
      server.toggle()
      return
    end
    vim.notify("pi: wezterm util missing, falling back to snacks", vim.log.levels.WARN)
  end

  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("pi: neither wezterm nor snacks available", vim.log.levels.ERROR)
    return
  end
  snacks.terminal.toggle("pi", { win = { position = "right", width = 0.4 } })
end

return {
  {
    "pablopunk/pi.nvim",
    cmd = { "PiAsk", "PiAskSelection", "PiCancel", "PiLog" },
    opts = {
      thinking = "off",
    },
    keys = {
      { "<leader>ii", "<cmd>PiAsk<cr>",          desc = "Pi: ask (buffer context)" },
      { "<leader>ii", "<cmd>PiAskSelection<cr>", desc = "Pi: ask (selection)",       mode = "v" },
      { "<leader>it", open_interactive_pi,       desc = "Pi: toggle interactive REPL" },
      { "<leader>ix", "<cmd>PiCancel<cr>",       desc = "Pi: cancel request" },
      { "<leader>iL", "<cmd>PiLog<cr>",          desc = "Pi: open session log" },
    },
  },
}
