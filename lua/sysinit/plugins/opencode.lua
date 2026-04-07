return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    keys = {
      {
        "<leader>oo",
        function()
          require("opencode").toggle()
        end,
        desc = "OpenCode: Toggle",
      },
      {
        "<leader>oa",
        function()
          require("opencode").ask("@this: ", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "OpenCode: Ask",
      },
      {
        "<leader>os",
        function()
          require("opencode").select()
        end,
        desc = "OpenCode: Select action",
      },
      {
        "<leader>or",
        function()
          require("opencode").prompt("review")
        end,
        mode = { "n", "x" },
        desc = "OpenCode: Review",
      },
      {
        "<leader>od",
        function()
          require("opencode").prompt("diff")
        end,
        desc = "OpenCode: Review diff",
      },
      {
        "<leader>on",
        function()
          require("opencode").command("session.new")
        end,
        desc = "OpenCode: New session",
      },
      {
        "<leader>ol",
        function()
          require("opencode").command("session.select")
        end,
        desc = "OpenCode: Select session",
      },
      {
        "<leader>oi",
        function()
          require("opencode").command("session.interrupt")
        end,
        desc = "OpenCode: Interrupt session",
      },
    },
  },
}
