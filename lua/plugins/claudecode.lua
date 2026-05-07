return {
  {
    "coder/claudecode.nvim",
    lazy = true,
    opts = {
      -- neph's claude-peer adapter calls start()/stop() on demand via the session
      -- lifecycle; disable auto-start so claudecode doesn't race with neph's init.
      auto_start = false,
      -- Open diffs in a dedicated tab instead of a vertical split so reviews
      -- don't crowd the surrounding workspace. Neph's review popup intercepts
      -- before this fires; the tab default is a fallback for cases where the
      -- override doesn't install.
      diff_opts = {
        open_in_new_tab = true,
      },
      -- Spawn the claude CLI in a wezterm split-pane via neph's helper, which
      -- captures the pane_id so neph's send/focus/kill ops can target the pane
      -- (otherwise <leader>ja and friends silently no-op for peer-claude). The
      -- helper also registers a VimLeavePre autocmd to kill the pane on exit.
      terminal = {
        provider = "external",
        provider_opts = {
          external_terminal_cmd = function(cmd_string, env_table)
            return require("neph.peers.claudecode").wezterm_pane_cmd(cmd_string, env_table)
          end,
        },
      },
    },
  },
}
