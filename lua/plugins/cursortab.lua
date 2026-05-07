return {
  "cursortab/cursortab.nvim",
  -- Temporarily disabled: caused 99.3%-CPU infinite loop in nlua_str_utfindex
  -- when opening nvim in certain dirs (e.g. /Users/roshan/.local/state/seshy/...).
  -- The cursortab Go daemon streams inline-completion events that can trigger
  -- a tight str_utfindex loop in vim.schedule callbacks, freezing nvim.
  -- Re-enable once upstream resolves the daemon's event-flood issue.
  enabled = false,
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
