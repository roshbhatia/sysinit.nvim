return {
  {
    "sourcegraph/amp.nvim",
    event = "VeryLazy",
    -- auto_start: launches the WebSocket IDE bridge so amp CLI can connect on startup.
    opts = { auto_start = true },
    keys = {
      {
        "<leader>jaj",
        function() Snacks.terminal.toggle("amp") end,
        desc = "Amp: toggle terminal",
      },
    },
  },
}
