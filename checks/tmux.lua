vim.opt.runtimepath:prepend(assert(vim.env.SYSINIT_NVIM_CONFIG))
vim.env.TMUX, vim.env.TMUX_PANE = nil, nil
vim.env.TMUX_TMPDIR = vim.fn.tempname()
vim.fn.mkdir(vim.env.TMUX_TMPDIR, "p")
local function tmux(...)
  local args = { "tmux" }
  vim.list_extend(args, { ... })
  local result = vim.system(args, { text = true }):wait(3000)
  assert(result.code == 0, result.stderr)
  return vim.trim(result.stdout)
end
local ok, err = xpcall(function()
  tmux("-f", "/dev/null", "new-session", "-d", "-s", "editor-test", "-x", "100", "-y", "30", "/bin/sh")
  vim.env.TMUX = tmux("display-message", "-p", "#{socket_path},#{pid},0")
  local left = tmux("display-message", "-p", "#{pane_id}")
  local right = tmux("split-window", "-h", "-P", "-F", "#{pane_id}", "/bin/sh")
  vim.env.TMUX_PANE = right
  local backend = require("utils.tmux_terminal").smart_splits_backend()
  assert(backend.detect())
  assert(backend.move("left"))
  assert(tmux("display-message", "-p", "#{pane_id}") == left, "editor edge did not select the adjacent tmux pane")
  vim.env.TMUX_PANE = left
  assert(not backend.move("left"), "outer edge wrapped to another pane")
  vim.env.TMUX_PANE = right
  local before = tmux("display-message", "-p", "-t", right, "#{pane_width}")
  assert(backend.resize("left", { amount = 3 }))
  assert(tmux("display-message", "-p", "-t", right, "#{pane_width}") ~= before, "backend did not resize the pane")
  tmux("resize-pane", "-t", right, "-Z")
  assert(not backend.move("left"), "zoomed editor changed panes")
end, debug.traceback)
pcall(tmux, "kill-server")
vim.fn.delete(vim.env.TMUX_TMPDIR, "rf")
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
print("Native tmux editor navigation, edges, resizing and zoom pass")
vim.cmd("qa!")
