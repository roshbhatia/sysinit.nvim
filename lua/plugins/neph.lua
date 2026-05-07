return {
  {
    "roshbhatia/neph.nvim",
    build = "bash scripts/build.sh",
    dependencies = {
      "folke/snacks.nvim",
      "folke/neoconf.nvim",
    },
    event = "VeryLazy",
    opts = function()
      return {
        agents = require("neph.agents.all"),
        backend = require("neph.backends.wezterm"),
        watchdog = { enable = true },
      }
    end,
    config = function(_, opts)
      require("neph").setup(opts)
      require("neph.api.review")
    end,
    keys = function()
      local api = require("neph.api")
      return {
        { "<leader>jj", api.toggle, desc = "Neph: toggle / pick agent" },
        { "<leader>jJ", api.kill_and_pick, desc = "Neph: kill & pick new agent" },
        { "<leader>jx", api.kill, desc = "Neph: kill active session" },
        { "<leader>ja", api.ask, mode = { "n", "v" }, desc = "Neph: ask active agent" },
        { "<leader>jf", api.fix, desc = "Neph: fix diagnostics" },
        { "<leader>jc", api.comment, mode = { "n", "v" }, desc = "Neph: comment selection" },
        { "<leader>jv", api.resend, desc = "Neph: resend previous prompt" },
        { "<leader>jr", api.review, desc = "Neph: review buffer changes" },
        { "<leader>jg", api.gate, desc = "Neph: cycle gate (normal→hold→bypass→normal)" },
        { "<leader>jn", api.tools_status, desc = "Neph: tools/integration status" },
        {
          "<leader>drr",
          function()
            api.diff_picker("head")
          end,
          desc = "Diff: browse HEAD",
        },
        {
          "<leader>drs",
          function()
            api.diff_picker("staged")
          end,
          desc = "Diff: browse staged",
        },
        {
          "<leader>drf",
          function()
            api.diff_picker("branch")
          end,
          desc = "Diff: browse branch",
        },
        {
          "<leader>dra",
          function()
            api.diff_review("head")
          end,
          desc = "Diff: review HEAD",
        },
        {
          "<leader>drS",
          function()
            api.diff_review("staged")
          end,
          desc = "Diff: review staged",
        },
        {
          "<leader>drb",
          function()
            api.diff_review("branch")
          end,
          desc = "Diff: review branch",
        },
        {
          "<leader>drF",
          function()
            api.diff_review("file")
          end,
          desc = "Diff: review file",
        },
        {
          "<leader>drh",
          function()
            api.diff_review("hunk")
          end,
          desc = "Diff: review hunk",
        },
      }
    end,
  },
}
