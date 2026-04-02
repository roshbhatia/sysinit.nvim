return {
  {
    "roshbhatia/neph.nvim",
    branch = "main",
    -- Compile TypeScript tools and install ~/.local/bin/neph after install/update.
    -- Requires node + npm on PATH. dist/ is committed so this is optional but recommended.
    build = "bash scripts/build.sh",
    dependencies = {
      "folke/snacks.nvim",
    },
    opts = function()
      return {
        agents = require("neph.agents.all"),
        backend = require("neph.backends.wezterm"),

        -- Auto-create Neovim RPC socket so agents can call back via nvim --server
        socket = { enable = true },

        -- Integration groups: agents in "hook" group get vimdiff review UI
        -- review_provider is resolved per-agent via integration_groups (not a global config key)
        integration_groups = {
          default = { policy_engine = "noop", review_provider = "noop", formatter = "noop" },
          hook = { policy_engine = "noop", review_provider = "vimdiff", formatter = "noop" },
          harness = { policy_engine = "cupcake", review_provider = "vimdiff", formatter = "noop" },
        },
        integration_default_group = "default",

        -- Filesystem watcher triggers review UI when an agent writes a file
        review = {
          fs_watcher = { enable = true },
          queue = { enable = true },
          pending_notify = true,
        },
      }
    end,
    keys = function()
      local api = require("neph.api")
      return {
        { "<leader>jj", api.toggle,        desc = "Neph: toggle / pick agent" },
        { "<leader>jJ", api.kill_and_pick, desc = "Neph: kill & pick new agent" },
        { "<leader>jx", api.kill,          desc = "Neph: kill active session" },
        { "<leader>ja", api.ask,  mode = { "n", "v" }, desc = "Neph: ask active agent" },
        { "<leader>jf", api.fix,           desc = "Neph: fix diagnostics" },
        { "<leader>jc", api.comment, mode = { "n", "v" }, desc = "Neph: comment selection" },
        { "<leader>jv", api.resend,        desc = "Neph: resend previous prompt" },
        { "<leader>jr", api.review,        desc = "Neph: review buffer changes" },
        { "<leader>jg", api.gate,          desc = "Neph: cycle review gate (normal→hold→bypass)" },
        { "<leader>jn", api.tools_status,  desc = "Neph: tools/integration status" },
      }
    end,
  },
}
