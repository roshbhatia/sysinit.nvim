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
    neoconf.register({
      name = "sysinit",
      on_schema = function(schema)
        -- Avante schema
        schema:import("avante", {
          provider = "copilot",
          openai = {
            model = "gpt-4o",
            temperature = 0,
            max_tokens = 4096,
          },
          claude = {
            model = "claude-3-5-sonnet-20240620",
            temperature = 0,
            max_tokens = 4096,
          },
        })

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
      end,
    })
  end,
}
