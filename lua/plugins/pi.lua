return {
  {
    "carderne/pi-nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>jpj", "<cmd>Pi<cr>", desc = "Pi: send prompt" },
      { "<leader>jpa", "<cmd>PiSendSelection<cr>", mode = { "n", "v" }, desc = "Pi: send selection" },
    },
  },
}
