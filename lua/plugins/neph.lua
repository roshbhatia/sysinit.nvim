return {
  {
    "roshbhatia/neph.nvim",
    dev = true,
    -- Compile TypeScript tools and install ~/.local/bin/neph after install/update.
    -- Requires node + npm on PATH. dist/ is committed so this is optional but recommended.
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

        -- Auto-create Neovim RPC socket so agents can call back via nvim --server
        socket = { enable = true },

        -- Integration groups: agents in "hook" group get vimdiff review UI
        -- review_provider is resolved per-agent via integration_groups (not a global config key)
        integration_groups = {
          default = { policy_engine = "noop", review_provider = "noop", formatter = "noop" },
          hook = { policy_engine = "noop", review_provider = "vimdiff", formatter = "noop" },
          harness = { policy_engine = "cupcake", review_provider = "vimdiff", formatter = "noop" },
          opencode_sse = { policy_engine = "noop", review_provider = "vimdiff", formatter = "noop" },
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
    config = function(_, opts)
      require("neph").setup(opts)
      -- Ensure the review queue has its UI opener registered before fs_watcher
      -- emits post-write reviews, preventing "set_open_fn not called" spam.
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

        -- Diff pickers (browse without sending to agent)
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

        -- Diff AI review (send to active agent)
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
