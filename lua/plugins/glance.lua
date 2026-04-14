return {
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    event = {
      "LSPAttach",
    },
    opts = {
      winbar = {
        enable = false,
      },
      border = {
        enable = true,
      },
      folds = {
        folded = false,
      },
      list = {
        position = "left",
      },
      preview_win_opts = {
        cursorline = false,
      },
    },
    keys = {
      { "<leader>gd", "<cmd>Glance definitions<cr>", desc = "Peek definition" },
      { "<leader>gi", "<cmd>Glance implementations<cr>", desc = "Peek implementation" },
      { "<leader>gu", "<cmd>Glance references<cr>", desc = "Peek references" },
    },
  },
}
