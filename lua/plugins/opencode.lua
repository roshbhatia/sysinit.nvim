return {
  {
    "nickjvandyke/opencode.nvim",
    event = "VeryLazy",
    opts = {
      window = {
        type = "split",
        position = "right",
        size = 40,
      },
    },
    keys = {
      { "<leader>joj", "<cmd>OpencodeToggle<cr>", desc = "OpenCode: toggle" },
    },
  },
}
