-- nvim-lspconfig is a *registry* of server configs in `lsp/<server>.lua`,
-- which `vim.lsp.config`/`vim.lsp.enable` auto-discover from runtimepath.
-- We use the native API in after/plugin/lsp.lua + after/lsp/*.lua and only
-- need this plugin on rtp at startup so the registry is visible.
--
-- Per upstream README:
--   require('lspconfig') is DEPRECATED — use vim.lsp.config/enable instead.
--   nvim-lspconfig itself is NOT deprecated; the lsp/ dir is the contract.
return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "b0o/SchemaStore.nvim",
      "saghen/blink.cmp",
      "Chaitanyabsprip/fastaction.nvim",
    },
  },
}
