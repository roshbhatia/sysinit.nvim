local busted = require("plenary.busted")
local assert = require("luassert")

local config_root = assert(vim.env.SYSINIT_NVIM_CONFIG)

busted.describe("plugin specifications", function()
  busted.it("loads every spec without duplicate plugins or lazy keys", function()
    local plugin_files = 0
    local plugin_ids = {}
    local lazy_keys = {}

    for name, kind in vim.fs.dir(config_root .. "/lua/plugins") do
      if kind == "file" and name:match("%.lua$") then
        plugin_files = plugin_files + 1
        local ok, specs = pcall(dofile, config_root .. "/lua/plugins/" .. name)
        assert.is_true(ok, name .. " did not load: " .. tostring(specs))
        assert.are.equal("table", type(specs), name .. " returned no plugin specs")
        if type(specs[1]) == "string" then
          specs = { specs }
        end
        for _, spec in ipairs(specs) do
          if type(spec) == "table" then
            local id = spec.name or spec[1]
            if type(id) == "string" then
              assert.is_nil(plugin_ids[id], string.format("duplicate plugin %s in %s and %s", id, plugin_ids[id], name))
              plugin_ids[id] = name
            end
            local bindings = type(spec.keys) == "table" and spec.keys or {}
            for _, binding in ipairs(bindings) do
              local modes = type(binding.mode) == "table" and binding.mode or { binding.mode or "n" }
              for _, mode in ipairs(modes) do
                local chord = mode .. "\0" .. tostring(binding[1])
                assert.is_nil(
                  lazy_keys[chord],
                  string.format("duplicate lazy key %s in %s and %s", binding[1], lazy_keys[chord], name)
                )
                lazy_keys[chord] = name
              end
            end
          end
        end
      end
    end

    assert.is_true(plugin_files > 0)
    assert.are.equal("harness.lua", plugin_ids.harness)
  end)

  busted.it("keeps Tree-sitter motions on the jump list", function()
    local move_config
    local movement_calls = {}
    local movement_maps = {}
    local original_setup = package.loaded["nvim-treesitter-textobjects"]
    local original_move = package.loaded["nvim-treesitter-textobjects.move"]
    local keymap_set = vim.keymap.set

    package.loaded["nvim-treesitter-textobjects"] = {
      setup = function(options)
        move_config = options.move
      end,
    }
    package.loaded["nvim-treesitter-textobjects.move"] = setmetatable({}, {
      __index = function(_, method)
        return function(capture, group)
          movement_calls[#movement_calls + 1] = { method = method, capture = capture, group = group }
        end
      end,
    })
    vim.keymap.set = function(_, lhs, callback, options)
      movement_maps[lhs] = { callback = callback, description = options.desc }
    end

    local specs = dofile(config_root .. "/lua/plugins/nvim-treesitter.lua")
    specs[2].config()

    vim.keymap.set = keymap_set
    package.loaded["nvim-treesitter-textobjects"] = original_setup
    package.loaded["nvim-treesitter-textobjects.move"] = original_move

    assert.is_true(move_config.set_jumps)
    movement_maps["]C"].callback()
    assert.are.same({ method = "goto_next_start", capture = "@class.outer", group = "textobjects" }, movement_calls[1])
  end)

  busted.it("registers the quit key group", function()
    local original = package.loaded["which-key"]
    local groups
    package.loaded["which-key"] = {
      setup = function() end,
      add = function(entries)
        groups = entries
      end,
    }

    local spec = dofile(config_root .. "/lua/plugins/which-key.lua")[1]
    spec.config()
    package.loaded["which-key"] = original

    local quit
    for _, entry in ipairs(groups) do
      if entry[1] == "<leader>q" then
        quit = entry
      end
    end
    assert.are.equal("Quit", quit.group)
  end)

  busted.it("uses tmux pane navigation and retains editor presence updates", function()
    local ui_send = vim.api.nvim_ui_send
    local create_autocmd = vim.api.nvim_create_autocmd
    local original_splits = package.loaded["smart-splits"]
    local messages = {}
    local autocmds = {}
    local split_options
    local original_mux = vim.g.smart_splits_multiplexer_integration
    local original_pane = vim.env.TMUX_PANE

    vim.api.nvim_ui_send = function(value)
      messages[#messages + 1] = value
    end
    rawset(vim.api, "nvim_create_autocmd", function(events, options)
      autocmds[#autocmds + 1] = { events = events, callback = options.callback }
      return #autocmds
    end)
    package.loaded["smart-splits"] = {
      setup = function(options)
        split_options = options
      end,
    }

    local spec = dofile(config_root .. "/lua/plugins/smart-splits.lua")[1]
    vim.env.TMUX_PANE = "%7"
    spec.init()
    spec.config()
    autocmds[1].callback()
    autocmds[2].callback()

    vim.api.nvim_ui_send = ui_send
    rawset(vim.api, "nvim_create_autocmd", create_autocmd)
    package.loaded["smart-splits"] = original_splits
    vim.g.smart_splits_multiplexer_integration = original_mux
    vim.env.TMUX_PANE = original_pane

    local function user_var(message)
      message = message:gsub("^\27Ptmux;\27\27", ""):gsub("\27\\\\$", "")
      local name, encoded = message:match("SetUserVar=([^=]+)=([^\7]+)")
      return name, vim.base64.decode(encoded)
    end

    local name, value = user_var(messages[1])
    assert.are.equal("IS_NVIM", name)
    assert.are.equal("true", value)
    name, value = user_var(messages[2])
    assert.are.equal("IS_NVIM", name)
    assert.are.equal("true", value)
    name, value = user_var(messages[3])
    assert.are.equal("IS_NVIM", name)
    assert.are.equal("false", value)
    assert.are.equal("tmux", split_options.multiplexer_integration)
  end)
end)
