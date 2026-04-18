return {
  {
    "coder/claudecode.nvim",
    event = "VeryLazy",
    opts = {
      terminal_cmd = "claude",
      split_side = "right",
      split_width_percentage = 0.35,
      auto_start = true,
    },
    keys = {
      { "<leader>jcj", "<cmd>ClaudeCode<cr>", desc = "Claude: toggle" },
      { "<leader>jca", "<cmd>ClaudeCodeSend<cr>", mode = { "n", "v" }, desc = "Claude: send selection" },
    },
  },
}
