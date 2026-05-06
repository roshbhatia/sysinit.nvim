return {
  {
    "coder/claudecode.nvim",
    lazy = true,
    opts = {
      -- neph's claude-peer adapter calls start()/stop() on demand via the session
      -- lifecycle; disable auto-start so claudecode doesn't race with neph's init.
      auto_start = false,
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
