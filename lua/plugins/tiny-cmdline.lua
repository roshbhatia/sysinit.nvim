-- lua/plugins/tiny-cmdline.lua
-- Floating command-line window replacing wilder.nvim.
-- Completion is handled by blink.cmp (cmdline mode).
return {
  {
    "rachartier/tiny-cmdline.nvim",
    event = "CmdlineEnter",
    opts = {
      cmdline = {
        -- Keep search at the native bottom bar; blink.cmp handles completions there.
        position = "center",
      },
      search = {
        position = "bottom",
      },
      window = {
        border = "rounded",
      },
      -- Reposition blink.cmp's completion menu under the floating cmdline window.
      integrations = {
        blink_cmp = {
          enabled = true,
        },
      },
    },
  },
}
