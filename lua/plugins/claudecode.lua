-- claudecode.nvim — Anthropic's Claude Code CLI integration.
--
-- Terminal provider:
--   default: snacks (folke/snacks.nvim)
--   override: set vim.g.claudecode_provider = "wezterm" to use wezterm
--             cli split-pane (parent pane tracked via $WEZTERM_PANE).
--             Falls back to snacks automatically when WEZTERM_PANE is unset
--             or wezterm isn't on PATH.
return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSelectModel",
      "ClaudeCodeAdd",
      "ClaudeCodeSend",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
    },
    opts = function()
      local provider = "auto"
      if vim.g.claudecode_provider == "wezterm" then
        local ok, wezterm = pcall(require, "utils.wezterm_terminal")
        if ok then
          local p = wezterm.build_provider({ name = "claudecode" })
          if p.is_available() then
            provider = p
          end
        end
      end

      return {
        terminal = {
          provider = provider,
          split_side = "right",
          split_width_percentage = 0.4,
        },
      }
    end,
    keys = {
      { "<leader>kk", "<cmd>ClaudeCode<cr>",            desc = "Claude: toggle" },
      { "<leader>kf", "<cmd>ClaudeCodeFocus<cr>",       desc = "Claude: focus" },
      { "<leader>kr", "<cmd>ClaudeCode --resume<cr>",   desc = "Claude: resume" },
      { "<leader>kC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continue" },
      { "<leader>km", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: select model" },
      { "<leader>kb", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Claude: add buffer" },
      { "<leader>ks", "<cmd>ClaudeCodeSend<cr>",        desc = "Claude: send selection", mode = "v" },
      {
        "<leader>ks",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Claude: add tree entry",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      { "<leader>ka", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff" },
      { "<leader>kd", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Claude: deny diff" },
    },
  },
}
