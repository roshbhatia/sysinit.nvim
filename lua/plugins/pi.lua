-- pi.nvim — minimal AI coding agent integration (badlogic/pi-mono).
--
-- pi.nvim is fire-and-forget: :PiAsk sends buffer+prompt as context, pi
-- edits files on disk, and the plugin reloads modified buffers.
--
-- Interactive REPL lifecycle (wezterm pane / snacks terminal) is now owned
-- by lua/harness/adapters/pi.lua via the harness lifecycle factory.
-- Keymaps live in lua/plugins/harness.lua under <leader>j*.
return {
  {
    "pablopunk/pi.nvim",
    cmd = { "PiAsk", "PiAskSelection", "PiCancel", "PiLog" },
    opts = {
      thinking = "off",
    },
  },
}
