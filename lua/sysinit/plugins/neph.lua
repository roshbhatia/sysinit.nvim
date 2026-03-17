return {
  {
    "roshbhatia/neph.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    opts = function()
      return {
        agents = require("neph.agents.all"),
        backend = require("neph.backends.wezterm"),
      }
    end,
    keys = function()
      local api = require("neph.api")
      return {
        {
          "<leader>jj",
          api.toggle,
          desc = "Toggle / pick agent",
        },
        {
          "<leader>jJ",
          api.kill_and_pick,
          desc = "Kill session & pick new",
        },
        {
          "<leader>jx",
          api.kill,
          desc = "Kill active session",
        },
        {
          "<leader>ja",
          api.ask,
          mode = { "n", "v" },
          desc = "Ask active",
        },
        {
          "<leader>jf",
          api.fix,
          desc = "Fix diagnostics",
        },
        {
          "<leader>jc",
          api.comment,
          mode = { "n", "v" },
          desc = "Comment",
        },
        {
          "<leader>jv",
          api.resend,
          desc = "Resend previous prompt",
        },
      }
    end,
  },
}
