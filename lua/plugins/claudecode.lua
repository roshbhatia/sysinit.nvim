return {
  {
    "coder/claudecode.nvim",
    lazy = true,
    opts = {
      -- neph's claude-peer adapter calls start()/stop() on demand via the session
      -- lifecycle; disable auto-start so claudecode doesn't race with neph's init.
      auto_start = false,
      -- Open diffs in a dedicated tab instead of a vertical split so reviews
      -- don't crowd the surrounding workspace. Falls through to neph's own
      -- review UI (also tab-based) once the peer-diff-integration override
      -- intercepts openDiff.
      diff_opts = {
        open_in_new_tab = true,
      },
      -- Spawn the claude CLI in a wezterm split-pane to the right of nvim, so the
      -- agent terminal lives outside nvim and matches the wezterm-backend UX neph
      -- uses for non-peer agents.
      terminal = {
        provider = "external",
        provider_opts = {
          external_terminal_cmd = function(cmd_string, _env_table)
            return {
              "wezterm",
              "cli",
              "split-pane",
              "--right",
              "--cwd",
              vim.fn.getcwd(),
              "--",
              "sh",
              "-c",
              cmd_string,
            }
          end,
        },
      },
    },
  },
}
