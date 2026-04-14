return {
  "folke/neoconf.nvim",
  priority = 1001,
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

    -- Scaffold .sysinit/neoconf.json for the current project
    vim.api.nvim_create_user_command("NeoconfInit", function()
      local root = vim.fn.getcwd()
      local dir = vim.fs.joinpath(root, ".sysinit")
      local path = vim.fs.joinpath(dir, "neoconf.json")

      if vim.uv.fs_stat(path) then
        vim.notify("neoconf: " .. path .. " already exists", vim.log.levels.WARN)
        return
      end

      vim.fn.mkdir(dir, "p")

      local template = [[{
  "lua_ls": { "settings": { "Lua": { "workspace": { "checkThirdParty": false } } } },
  "gopls": { "settings": { "gopls": {} } },
  "pyright": { "settings": { "python": {} } },
  "yamlls": { "settings": { "yaml": {} } },
  "jsonls": { "settings": { "json": {} } }
}
]]

      local fd = io.open(path, "w")
      if not fd then
        vim.notify("neoconf: failed to write " .. path, vim.log.levels.ERROR)
        return
      end
      local ok, err = pcall(function()
        fd:write(template)
        fd:close()
      end)
      if ok then
        vim.notify("neoconf: created " .. path)
        vim.cmd.edit(path)
      else
        vim.notify("neoconf: write error: " .. tostring(err), vim.log.levels.ERROR)
      end
    end, { desc = "Scaffold .sysinit/neoconf.json for this project" })
  end,
}
