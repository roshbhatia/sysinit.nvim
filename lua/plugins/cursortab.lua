return {
  "cursortab/cursortab.nvim",
  lazy = false,
  build = "cd server && go build",
  config = function()
    require("cursortab").setup({
      provider = {
        type = "copilot",
      },
      blink = {
        enabled = true,
        ghost_text = false, -- blink.cmp handles ghost text; avoids duplicate overlay with blink-copilot
      },
    })
  end,
}
