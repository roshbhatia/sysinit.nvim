-- Enable semantic tokens for better markdown highlighting
local config = {
  settings = {
    marksman = {
      -- Enable all features
      features = {
        semanticTokens = true,
      },
    },
  },
  capabilities = vim.tbl_deep_extend(
    "force",
    require("blink.cmp").get_lsp_capabilities(),
    {
      textDocument = {
        semanticTokens = {
          dynamicRegistration = true,
        },
      },
    }
  ),
}

return config
