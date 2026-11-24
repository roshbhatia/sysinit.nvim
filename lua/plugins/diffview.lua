return {
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFileHistory",
      "DiffviewRefresh",
    },
    opts = {},
    keys = {
      {
        "<leader>dd",
        "<cmd>DiffviewOpen<cr>",
        desc = "Open diff",
        mode = "n",
      },
      {
        "<leader>dh",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "File history",
        mode = "n",
      },
      {
        "<leader>dH",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "Project history",
        mode = "n",
      },
    },
  },
}
