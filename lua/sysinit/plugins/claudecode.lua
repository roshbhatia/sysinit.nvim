return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>k", nil, desc = "Claude: Commands" },
      { "<leader>kk", "<cmd>ClaudeCode<cr>", desc = "Claude: Toggle" },
      { "<leader>kf", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: Focus" },
      { "<leader>kr", "<cmd>ClaudeCode --resume<cr>", desc = "Claude: Resume" },
      { "<leader>kC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: Continue" },
      { "<leader>km", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: Select model" },
      { "<leader>kb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: Add current buffer" },
      { "<leader>ka", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: Send selection" },
      {
        "<leader>ka",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Claude: Add file",
        ft = { "neo-tree", "oil" },
      },
      -- Diff management
      { "<leader>kg", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: Accept diff" },
      { "<leader>kx", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: Deny diff" },
    },
  },
}
