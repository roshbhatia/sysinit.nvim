vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- ~/.gitconfig often sets url.git@github.com:.insteadOf=https://github.com/, which forces SSH.
-- Lazy passes https URLs, but git rewrites them to git@github.com — broken when SSH to GitHub fails.
vim.env.GIT_CONFIG_GLOBAL = vim.fn.stdpath("config") .. "/gitconfig-lazy"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    {
      import = "sysinit.plugins",
    },
  },
  git = {
    -- Use HTTPS instead of SSH to avoid connection issues
    url_format = "https://github.com/%s.git",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
  },
})
