local busted = require("plenary.busted")
local assert = require("luassert")

busted.describe("privileged buffer writes", function()
  local directory, old_path, old_notify

  busted.before_each(function()
    directory = vim.fn.tempname()
    vim.fn.mkdir(directory, "p")
    old_path = vim.env.PATH
    old_notify = vim.notify
    vim.env.PATH = directory .. ":" .. old_path
    vim.notify = function() end
    dofile(vim.env.SYSINIT_NVIM_CONFIG .. "/after/plugin/sudo.lua")
  end)

  busted.after_each(function()
    vim.cmd("bwipeout!")
    vim.env.PATH = old_path
    vim.notify = old_notify
    vim.fn.delete(directory, "rf")
  end)

  local function sudo_script(lines)
    vim.fn.writefile(lines, directory .. "/sudo")
    vim.fn.setfperm(directory .. "/sudo", "rwx------")
  end

  busted.it("preserves edits when sudo fails", function()
    sudo_script({ "#!/bin/sh", "exit 1" })
    local file = directory .. "/file"
    vim.fn.writefile({ "original" }, file)
    vim.cmd.edit(vim.fn.fnameescape(file))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "unsaved" })
    vim.cmd.Wsudo()
    assert.are.same({ "unsaved" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    assert.is_true(vim.bo.modified)
    assert.are.same({ "original" }, vim.fn.readfile(file))
  end)

  busted.it("writes literal shell characters without expanding them", function()
    sudo_script({ "#!/bin/sh", 'exec "$@"' })
    local file = directory .. "/quote' \" $(touch PWNED) ! % #.txt"
    vim.cmd.edit(vim.fn.fnameescape(file))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "saved" })
    vim.cmd.Wsudo()
    assert.are.same({ "saved" }, vim.fn.readfile(file))
    assert.is_false(vim.bo.modified)
    assert.are.equal(0, vim.fn.filereadable("PWNED"))
  end)
end)

busted.describe("formatter ownership", function()
  local get_clients, format
  busted.before_each(function()
    get_clients, format = vim.lsp.get_clients, vim.lsp.buf.format
  end)
  busted.after_each(function()
    vim.lsp.get_clients, vim.lsp.buf.format = get_clients, format
  end)

  busted.it("selects one formatter for both range and buffer requests", function()
    local requests = {}
    vim.lsp.get_clients = function(options)
      table.insert(requests, options.method)
      return { { id = 1, name = "lua_ls" }, { id = 2, name = "null-ls" } }
    end
    local calls = {}
    vim.lsp.buf.format = function(options)
      table.insert(calls, options)
    end
    local formatter = require("utils.formatting")
    formatter.format()
    formatter.format({ range = { start = { 1, 0 }, ["end"] = { 1, 3 } } })
    assert.are.equal(2, #calls)
    assert.are.equal(2, calls[1].id)
    assert.are.equal(2, calls[2].id)
    assert.is_false(calls[1].async)
    assert.are.same({ "textDocument/formatting", "textDocument/rangeFormatting" }, requests)
  end)

  busted.it("does nothing without a capable formatter", function()
    vim.lsp.get_clients = function()
      return {}
    end
    vim.lsp.buf.format = function()
      error("no formatter should run")
    end
    require("utils.formatting").format()
  end)
end)

busted.describe("WezTerm UI routing", function()
  busted.it("uses the UI channel and disables the duplicate mux owner", function()
    local old_term, old_send = vim.env.TERM_PROGRAM, vim.api.nvim_ui_send
    local old_mux = vim.g.smart_splits_multiplexer_integration
    local messages = {}
    vim.env.TERM_PROGRAM = "WezTerm"
    vim.api.nvim_ui_send = function(value)
      table.insert(messages, value)
    end
    dofile(vim.env.SYSINIT_NVIM_CONFIG .. "/lua/plugins/smart-splits.lua")[1].init()
    assert.is_false(vim.g.smart_splits_multiplexer_integration)
    assert.are.equal(1, #messages)
    assert.is_truthy(messages[1]:find("IS_NVIM", 1, true))
    vim.api.nvim_ui_send = old_send
    vim.env.TERM_PROGRAM = old_term
    vim.g.smart_splits_multiplexer_integration = old_mux
  end)
end)
