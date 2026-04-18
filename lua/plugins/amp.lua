return {
  {
    "sourcegraph/amp.nvim",
    event = "VeryLazy",
    opts = {
      split = "right",
      width = 80,
    },
    keys = {
      { "<leader>jaj", "<cmd>Amp<cr>", desc = "Amp: toggle" },
      { "<leader>jaa", "<cmd>AmpSendSelection<cr>", mode = { "n", "v" }, desc = "Amp: send selection" },
    },
  },
}
