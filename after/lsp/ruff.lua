local neoconf = require("neoconf")

local base_config = {
  init_options = {
    settings = {},
  },
}

return vim.tbl_deep_extend("force", base_config, neoconf.get("ruff") or {})
