local M = {}

function M.host_pane()
  return vim.env.TMUX_PANE or vim.env.WEZTERM_PANE
end

function M.backend()
  return require(vim.env.TMUX_PANE and "utils.tmux_terminal" or "utils.wezterm_terminal")
end

return M
