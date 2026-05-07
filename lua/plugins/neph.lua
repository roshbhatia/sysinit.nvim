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
      "coder/claudecode.nvim",
      "nickjvandyke/opencode.nvim",
    },
    event = "VeryLazy",
    opts = function()
      return {
        agents = require("neph.agents.all"),
        backend = require("neph.backends.wezterm"),

        -- Auto-create Neovim RPC socket so agents can call back via nvim --server
        socket = { enable = true },

        -- Integration groups drive review_provider resolution per-agent.
        -- "hook" + "harness" → vimdiff review UI; "default" → noop (auto-accept).
        -- (The opencode_sse group was removed in peer-diff-integration; opencode
        -- peer now intercepts permissions via opencode.nvim's User autocmds.)
        integration_groups = {
          default = { policy_engine = "noop", review_provider = "noop", formatter = "noop" },
          hook = { policy_engine = "noop", review_provider = "vimdiff", formatter = "noop" },
          harness = { policy_engine = "cupcake", review_provider = "vimdiff", formatter = "noop" },
        },
        integration_default_group = "default",

        -- Review pipeline. The popup style is the default for peer agents
        -- (claude, opencode); set `style = "tab"` to force the vimdiff tab UI.
        review = {
          fs_watcher = { enable = true },
          queue = { enable = true },
          pending_notify = true,
          -- style = "popup",  -- uncomment to force popup for ALL agents
        },

        -- Slow-callback watchdog: logs WARN when any instrumented callback
        -- exceeds the threshold. Cheap to leave on; gives a breadcrumb trail
        -- if the plugin ever locks up. Set NEPH_DEBUG=1 in env to also flush
        -- per-line debug logs to /tmp/neph-debug-<pid>.log.
        watchdog = { enable = true, threshold_ms = 200 },
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
