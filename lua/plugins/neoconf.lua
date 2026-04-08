return {
  "folke/neoconf.nvim",
  priority = 1000,
  opts = {
    local_settings = ".sysinit/neoconf.json",
    global_settings = "neoconf.json",
  },
  config = function(_, opts)
    local neoconf = require("neoconf")
    neoconf.setup(opts)

    -- Register custom schemas for autocompletion in .sysinit/neoconf.json
    require("neoconf.plugins").register({
      name = "sysinit",
      on_schema = function(schema)
        -- Conform schema
        schema:import("conform", {
          autoformat = true,
          formatters_by_ft = {
            lua = { "stylua" },
          },
        })

        -- LSP AI schema
        schema:import("lsp_ai", {
          init_options = {},
        })

        -- Common LSP server settings (placeholders for autocomplete)
        schema:import("lua_ls", { settings = { Lua = {} } })
        schema:import("gopls", { settings = { gopls = {} } })
        schema:import("pyright", { settings = { python = {} } })
        schema:import("yamlls", { settings = { yaml = {} } })
        schema:import("jsonls", { settings = { json = {} } })
        schema:import("eslint", { settings = {} })
        schema:import("graphql", {})
        schema:import("bashls", {})
        schema:import("dockerls", {})
        schema:import("docker_compose_language_service", {})
        schema:import("ruff", { init_options = { settings = {} } })
        schema:import("typescript_tools", {})
      end,
    })
  end,
}
