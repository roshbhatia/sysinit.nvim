-- opencode.nvim — opencode CLI integration. Terminal is snacks-only (hard
-- dependency in upstream); wezterm provider only applies to claudecode.
return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    dependencies = { "folke/snacks.nvim" },
    cmd = {},
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        auto_reload = true,
        terminal = { win = { position = "right" } },
      }
    end,
    keys = {
      {
        "<leader>la",
        function()
          require("opencode").ask("@cursor: ", { submit = true })
        end,
        desc = "Opencode: ask about cursor",
      },
      {
        "<leader>la",
        function()
          require("opencode").ask("@selection: ", { submit = true })
        end,
        mode = "x",
        desc = "Opencode: ask about selection",
      },
      {
        "<leader>ll",
        function()
          require("opencode").toggle()
        end,
        desc = "Opencode: toggle",
      },
      {
        "<leader>ln",
        function()
          require("opencode").command("session_new")
        end,
        desc = "Opencode: new session",
      },
      {
        "<leader>lS",
        function()
          require("opencode").command("session_interrupt")
        end,
        desc = "Opencode: interrupt session",
      },
      {
        "<leader>lp",
        function()
          require("opencode").select()
        end,
        desc = "Opencode: quick action",
      },
      {
        "<leader>lP",
        function()
          require("opencode").prompts()
        end,
        desc = "Opencode: prompts",
      },
      {
        "<leader>le",
        function()
          require("opencode").prompt("explain")
        end,
        desc = "Opencode: explain",
      },
      {
        "<leader>lr",
        function()
          require("opencode").prompt("review_buffer")
        end,
        desc = "Opencode: review buffer",
      },
      {
        "<leader>lf",
        function()
          require("opencode").prompt("fix_diagnostic")
        end,
        desc = "Opencode: fix diagnostic",
      },
      {
        "<leader>ly",
        function()
          require("opencode").command("messages_copy")
        end,
        desc = "Opencode: copy last message",
      },
      {
        "<leader>lc",
        function()
          require("opencode").command("/compact")
        end,
        desc = "Opencode: compact session",
      },
      {
        "<leader>lC",
        function()
          require("opencode").command("/clear")
        end,
        desc = "Opencode: clear session",
      },
      {
        "<leader>lA",
        function()
          require("opencode").command("agent_cycle")
        end,
        desc = "Opencode: cycle agent",
      },
    },
  },
}
