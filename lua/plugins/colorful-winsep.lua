return {
  {
    "nvim-zh/colorful-winsep.nvim",
    config = function()
      require("colorful-winsep").setup({
        border = "rounded",
        animate = {
          enabled = "false",
        },
      })
    end,
    event = { "WinLeave" },
  },
}
