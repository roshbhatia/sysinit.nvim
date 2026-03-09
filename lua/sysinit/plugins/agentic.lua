return {
  {
    "carlos-algms/agentic.nvim",
    opts = {
      provider = "claude-acp",
      acp_providers = {
        -- Agentic doesn't support adding custom ones, but we can ovveride the default?
        ["claude-acp"] = {
          command = "~/.local/share/npm-packages/bin/pi-acp",
        },
      },
    },
    keys = {
      {
        "<leader>kk",
        function()
          require("agentic").toggle()
        end,
        mode = { "n", "v", "i" },
        desc = "Toggle Agentic Chat",
      },
      {
        "<leader>ka",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Add file or selection to context",
      },
      {
        "<leader>ks",
        function()
          require("agentic").add_selection()
        end,
        mode = { "v" },
        desc = "Add selection to context",
      },
      {
        "<leader>kf",
        function()
          require("agentic").add_file()
        end,
        mode = { "n" },
        desc = "Add file to context",
      },
      {
        "<leader>kn",
        function()
          require("agentic").new_session_with_provider()
        end,
        mode = { "n", "v", "i" },
        desc = "New Agentic session (pick provider)",
      },
      {
        "<leader>kr",
        function()
          require("agentic").restore_session()
        end,
        mode = { "n", "v", "i" },
        desc = "Restore Agentic session",
      },
      {
        "<leader>kd",
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        mode = { "n" },
        desc = "Add current line diagnostics to context",
      },
      {
        "<leader>kD",
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        mode = { "n" },
        desc = "Add buffer diagnostics to context",
      },
      {
        "<leader>kx",
        function()
          require("agentic").stop_generation()
        end,
        mode = { "n" },
        desc = "Stop generation",
      },
      {
        "<leader>kp",
        function()
          require("agentic").switch_provider()
        end,
        mode = { "n" },
        desc = "Switch ACP provider",
      },
    },
  },
}
