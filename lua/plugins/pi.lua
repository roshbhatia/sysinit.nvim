-- pi.nvim — minimal AI coding agent integration (badlogic/pi-mono).
--
-- pi.nvim itself is fire-and-forget: :PiAsk sends buffer+prompt as context,
-- pi edits files on disk, plugin reloads buffers. No embedded terminal of
-- its own.
--
-- For interactive REPL mode we wire <leader>kk to an out-of-process pi
-- session in a wezterm pane split (snacks fallback when not in wezterm),
-- mirroring the toggle pattern used by claudecode/opencode/amp.
local function toggle_pi_repl()
  local choice = vim.g.pi_provider or "auto"
  if choice == "auto" then
    local in_wezterm = vim.env.WEZTERM_PANE ~= nil and vim.fn.executable("wezterm") == 1
    choice = in_wezterm and "wezterm" or "snacks"
  end

  if choice == "wezterm" then
    local ok, wezterm = pcall(require, "utils.wezterm_terminal")
    if ok then
      if not vim.g._pi_server then
        vim.g._pi_server = wezterm.build_server_callbacks("pi", { name = "pi", percent = 0.4 })
      end
      vim.g._pi_server.toggle()
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
      -- Match jj/hh/ll convention: <prefix><prefix> = toggle interactive session
      { "<leader>kk", toggle_pi_repl,                desc = "Pi: toggle interactive REPL" },
      -- Fire-and-forget one-shot (pi.nvim's native model)
      { "<leader>ka", "<cmd>PiAsk<cr>",              desc = "Pi: ask (buffer context)" },
      { "<leader>ks", "<cmd>PiAskSelection<cr>",     desc = "Pi: ask (selection)",         mode = "v" },
      { "<leader>kx", "<cmd>PiCancel<cr>",           desc = "Pi: cancel request" },
      { "<leader>kL", "<cmd>PiLog<cr>",              desc = "Pi: open session log" },
    },
  },
}
