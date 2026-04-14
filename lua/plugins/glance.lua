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
    keys = function()
      return {
        {
          "<leader>gd",
          function()
            vim.cmd("Glance definitions")
          end,
          desc = "Peek definition",
        },
        {
          "<leader>gi",
          "<CMD>Glance implementations<CR>",
          desc = "Peek implementation",
        },
        {
          "<leader>gu",
          function()
            vim.cmd("Glance references")
          end,
          desc = "Peek references",
        },
      }
    end,
  },
}
