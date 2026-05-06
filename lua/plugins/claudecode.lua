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
      --
      -- `wezterm cli split-pane` exits as soon as the wezterm daemon accepts the
      -- spawn, so claudecode's external provider can't kill the resulting pane on
      -- close. We capture the new pane_id (printed to stdout by `split-pane`)
      -- into a tempfile and register a VimLeavePre autocmd that kills the pane
      -- when nvim exits — otherwise the claude CLI keeps running orphaned.
      terminal = {
        provider = "external",
        provider_opts = {
          external_terminal_cmd = function(cmd_string, _env_table)
            local pane_file = vim.fn.tempname() .. ".claude-pane-id"

            vim.api.nvim_create_autocmd("VimLeavePre", {
              group = vim.api.nvim_create_augroup("ClaudecodeWeztermCleanup", { clear = true }),
              once = true,
              callback = function()
                local f = io.open(pane_file, "r")
                if not f then
                  return
                end
                local pane_id = (f:read("*l") or ""):gsub("%s+", "")
                f:close()
                pcall(os.remove, pane_file)
                if pane_id ~= "" then
                  vim.fn.system({ "wezterm", "cli", "kill-pane", "--pane-id", pane_id })
                end
              end,
            })

            return {
              "sh",
              "-c",
              string.format(
                "wezterm cli split-pane --right --cwd %s -- sh -c %s > %s",
                vim.fn.shellescape(vim.fn.getcwd()),
                vim.fn.shellescape(cmd_string),
                vim.fn.shellescape(pane_file)
              ),
            }
          end,
        },
      },
    },
  },
}
