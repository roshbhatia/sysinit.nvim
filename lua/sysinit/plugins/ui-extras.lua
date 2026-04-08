return {
  {
    "jake-stewart/auto-cmdheight.nvim",
    lazy = false,
    opts = {
      -- max cmdheight before displaying hit enter prompt.
      max_lines = 0,

      -- number of seconds until the cmdheight can restore.
      duration = 0,

      -- whether key press is required to restore cmdheight.
      remove_on_key = true,

      -- always clear the cmdline after duration and key press so stale
      -- message text doesn't linger after cmdheight collapses back to 0.
      clear_always = true,
    },
  },
  {
    "yaocccc/nvim-foldsign",
    event = "VeryLazy",
    config = function()
      require("nvim-foldsign").setup({
        offset = -3,
        foldsigns = {
          open = "*", -- mark the beginning of a fold
          close = "-", -- show a closed fold
          seps = { "│", "┃" }, -- open fold middle marker
        },
        enabled = true,
      })
    end,
  },
  {
    "rachartier/tiny-glimmer.nvim",
    event = "VeryLazy",
    config = function()
      local hl_utils = require("sysinit.utils.highlight")

      require("tiny-glimmer").setup({
        transparency_color = hl_utils.get_fg("Normal"),
        overwrite = {
          search = { enabled = true },
          undo = { enabled = true, undo_mapping = "u" },
          redo = { enabled = true, redo_mapping = "U" },
        },
      })
    end,
  },
  {
    "rachartier/tiny-devicons-auto-colors.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "catppuccin/nvim",
    },
    event = "VeryLazy",
    config = function()
      require("tiny-devicons-auto-colors").setup({})
    end,
  },
}
