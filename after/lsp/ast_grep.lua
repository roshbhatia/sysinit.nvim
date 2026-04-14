local neoconf = require("neoconf")

local base_config = {
  filetypes = {
    "bash",
    "c",
    "cpp",
    "go",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "lua",
    "python",
    "rust",
    "typescript",
    "typescriptreact",
  },
  root_markers = {
    "ast-grep.yml",
    "sgconfig.yml",
    ".git",
  },
  single_file_support = true,
}

return vim.tbl_deep_extend("force", base_config, neoconf.get("ast_grep") or {})
