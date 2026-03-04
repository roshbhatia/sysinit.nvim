-- Load theme configuration from environment variables (set by home-manager)
local nix_managed = vim.env.SYSINIT_NVIM_NIX_MANAGED == "true"
local theme_family = vim.env.SYSINIT_NVIM_COLORSCHEME_FAMILY
local theme_variant = vim.env.SYSINIT_NVIM_COLORSCHEME_VARIANT
local theme_appearance = vim.env.SYSINIT_NVIM_COLORSCHEME_APPEARANCE
local transparency = vim.env.SYSINIT_NVIM_TRANSPARENCY

-- Store theme config for plugin configuration
vim.g.sysinit_nix_managed = nix_managed
vim.g.sysinit_theme = {
  family = theme_family or "catppuccin",
  variant = theme_variant or "latte",
  appearance = theme_appearance or "light",
  transparency = transparency == "true",
}

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

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
