vim.loader.enable()

vim.o.sessionoptions = "blank,buffers,curdir,folds,tabpages,winsize,winpos,localoptions"

vim.o.winborder = "rounded"

vim.g.mapleader = " "
vim.g.maplocalleader = ","

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

local lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json"
if vim.fn.filereadable(lockfile) == 0 then
  vim.fn.mkdir(vim.fn.stdpath("state"), "p")
  local seed = vim.fn.stdpath("config") .. "/lazy-lock.json"
  if vim.fn.filereadable(seed) == 1 then
    assert(vim.uv.fs_copyfile(seed, lockfile))
  end
end

require("lazy").setup({
  lockfile = lockfile,
  dev = {
    path = "~/github/personal/roshbhatia",
    fallback = true,
  },
  spec = {
    {
      import = "plugins",
    },
  },
  install = {
    colorscheme = {
      "catppuccin",
    },
  },
  performance = {
    reset_packpath = false,
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
})
