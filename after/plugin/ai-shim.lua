-- Auto-install agent tools bundled in tools/ whenever nvim starts.
--
--   tools/shim.py  → ~/.local/bin/shim
--   tools/pi.ts    → ~/.pi/agent/extensions/nvim.ts
--
-- Both are symlinked so edits to the repo files take effect immediately
-- without re-running any installer.

local config = vim.fn.stdpath("config")

local function symlink(src, dst)
  if vim.fn.filereadable(src) == 0 then return end
  vim.fn.mkdir(vim.fn.fnamemodify(dst, ":h"), "p")
  vim.fn.system({ "ln", "-sf", src, dst })
end

symlink(
  config .. "/tools/shim.py",
  vim.fn.expand("~/.local/bin/shim")
)

symlink(
  config .. "/tools/pi.ts",
  vim.fn.expand("~/.pi/agent/extensions/nvim.ts")
)
