local neoconf = require("neoconf")

local base_config = {
  filetypes = {
    "bash",
    "sh",
    "zsh",
  },
  root_markers = {
    ".git",
  },
}

return vim.tbl_deep_extend("force", base_config, neoconf.get("bashls") or {})
