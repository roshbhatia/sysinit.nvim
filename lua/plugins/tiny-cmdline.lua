return {
  {
    "rachartier/tiny-cmdline.nvim",
    event = "UIEnter",
    config = function()
      require("tiny-cmdline").setup({
        width = {
          value = 80,
          min = 80,
          max = 80,
        },
        position = {
          y = "33%",
        },
        on_reposition = require("tiny-cmdline").adapters.blink,
      })
    end,
  },
}
