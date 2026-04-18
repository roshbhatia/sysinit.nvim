return {
  {
    "carderne/pi-nvim",
    event = "VeryLazy",
    opts = {
      backend = "wezterm",
      wezterm_direction = "Right",
      wezterm_size = 0.35,
    },
    keys = {
      { "<leader>jpj", "<cmd>Pi<cr>", desc = "Pi: toggle" },
      { "<leader>jpa", "<cmd>PiSendSelection<cr>", mode = { "n", "v" }, desc = "Pi: send selection" },
    },
  },
}
