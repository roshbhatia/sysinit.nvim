return {
  {
    -- "roshbhatia/neph.nvim",
    dir = vim.fn.expand("~/github/personal/roshbhatia/neph.nvim"),
    name = "neph.nvim",
    dependencies = {
      "folke/snacks.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Saghen/blink.cmp",
    },
    opts = {
      multiplexer = "wezterm",
    },
    keys = function()
      local api = require("neph.api")
      return {
        { "<leader>jj", api.toggle, desc = "Neph: toggle / pick agent" },
        { "<leader>jJ", api.kill_and_pick, desc = "Neph: kill session & pick new" },
        { "<leader>jx", api.kill, desc = "Neph: kill active session" },
        { "<leader>ja", api.ask, mode = { "n", "v" }, desc = "Neph: ask active" },
        { "<leader>jf", api.fix, desc = "Neph: fix diagnostics" },
        { "<leader>jc", api.comment, mode = { "n", "v" }, desc = "Neph: comment" },
        { "<leader>jv", api.resend, desc = "Neph: resend previous prompt" },
        { "<leader>jh", api.history, desc = "Neph: browse prompt history" },
      }
    end,
  },
}
