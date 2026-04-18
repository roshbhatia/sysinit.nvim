return {
  {
    "nickjvandyke/opencode.nvim",
    event = "VeryLazy",
    -- No opts: plugin is configured via vim.g.opencode_opts and has no setup() function.
    -- Default server.toggle/start/stop use opencode.terminal internally.
    keys = {
      { "<leader>joj", function() require("opencode").toggle() end, desc = "OpenCode: toggle" },
      { "<leader>joa", function() require("opencode").ask() end, desc = "OpenCode: ask" },
    },
  },
}
