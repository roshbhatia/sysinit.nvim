return {
  {
    -- "roshbhatia/neph.nvim",
    -- Local checkout used during development; swap to the string above once published.
    dir = vim.fn.expand("~/github/personal/roshbhatia/neph.nvim"),
    name = "neph.nvim",
    dependencies = {
      "folke/snacks.nvim", -- notifications and picker UI
      "nvim-treesitter/nvim-treesitter", -- syntax-aware context extraction
      "Saghen/blink.cmp", -- completion integration
    },
    opts = {
      -- Terminal multiplexer used to open the agent pane.
      multiplexer = "snacks",
    },
    keys = function()
      local api = require("neph.api")
      return {
        -- Session management
        { "<leader>jj", api.toggle, desc = "Neph: toggle / pick agent" },
        { "<leader>jJ", api.kill_and_pick, desc = "Neph: kill session & pick new" },
        { "<leader>jx", api.kill, desc = "Neph: kill active session" },

        -- Prompting (ask/fix/comment all accept visual selections)
        { "<leader>ja", api.ask, mode = { "n", "v" }, desc = "Neph: ask active" },
        { "<leader>jf", api.fix, desc = "Neph: fix diagnostics" },
        { "<leader>jc", api.comment, mode = { "n", "v" }, desc = "Neph: comment" },

        -- History / replay
        { "<leader>jv", api.resend, desc = "Neph: resend previous prompt" },
        { "<leader>jh", api.history, desc = "Neph: browse prompt history" },
      }
    end,
  },
}
