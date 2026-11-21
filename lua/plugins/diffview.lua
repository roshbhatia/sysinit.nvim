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
    config = function()
      require("utils.diffview").setup()
    end,
    keys = {
      {
        "<leader>dd",
        function()
          if require("diffview.lib").get_current_view() then
            vim.cmd.DiffviewClose()
          else
            vim.cmd.DiffviewOpen()
          end
        end,
        desc = "Toggle diff",
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
