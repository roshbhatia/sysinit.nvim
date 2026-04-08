return {
  {
    "smjonas/live-command.nvim",
    event = "VeryLazy",
    config = function()
      require("live-command").setup()
    end,
  },
  {
    "nmac427/guess-indent.nvim",
    event = "InsertEnter",
    config = function()
      require("guess-indent").setup({})
    end,
  },
  {
    "sQVe/sort.nvim",
    cmd = "Sort",
    config = function()
      require("sort").setup({
        delimiters = {
          ",",
          "|",
          ";",
          ":",
          "s",
          "t",
          "\n",
        },
      })
    end,
  },
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
