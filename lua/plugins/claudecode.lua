-- claudecode.nvim — Anthropic's Claude Code CLI integration.
--
-- Terminal provider selection:
--   auto-detect (default):
--     - wezterm pane-split when $WEZTERM_PANE is set and `wezterm` is on PATH
--     - snacks otherwise
--   override: vim.g.claudecode_provider = "wezterm" | "snacks" | "auto"
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
      local choice = vim.g.claudecode_provider or "auto"
      if choice == "auto" then
        local in_wezterm = vim.env.WEZTERM_PANE ~= nil and vim.fn.executable("wezterm") == 1
        choice = in_wezterm and "wezterm" or "snacks"
      end

      local provider = "auto"
      if choice == "wezterm" then
        local ok, wezterm = pcall(require, "utils.wezterm_terminal")
        if ok then
          local p = wezterm.build_provider({ name = "claudecode" })
          if p.is_available() then
            provider = p
          else
            vim.notify(
              "claudecode: wezterm provider unavailable, falling back to snacks",
              vim.log.levels.WARN
            )
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
