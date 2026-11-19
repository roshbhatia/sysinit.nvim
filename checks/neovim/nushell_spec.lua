local busted = require("plenary.busted")
local assert = require("luassert")

local config_root = assert(vim.env.SYSINIT_NVIM_CONFIG)

busted.describe("Nushell editing", function()
  busted.it("detects scripts and Nuon data files", function()
    dofile(config_root .. "/after/plugin/filetypes.lua")

    assert.are.equal("nu", vim.filetype.match({ filename = "fixture.nu" }))
    assert.are.equal("nu", vim.filetype.match({ filename = "fixture.nuon" }))
  end)

  busted.it("parses and highlights Nushell with the real Tree-sitter grammar", function()
    vim.opt.runtimepath:prepend(assert(vim.env.SYSINIT_NVIM_NU_PARSER))
    vim.opt.runtimepath:prepend(assert(vim.env.SYSINIT_NVIM_NU_QUERIES))

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "let value = 42", "$value + 1" })
    vim.bo[buffer].filetype = "nu"

    local parser = vim.treesitter.get_parser(buffer, "nu")
    local tree = parser:parse()[1]

    assert.is_false(tree:root():has_error())
    assert.is_not_nil(vim.treesitter.query.get("nu", "highlights"))

    vim.treesitter.start(buffer, "nu")
    assert.is_not_nil(vim.treesitter.highlighter.active[buffer])

    vim.api.nvim_buf_delete(buffer, { force = true })
  end)

  busted.it("receives diagnostics from the native Nushell language server", function()
    local buffer = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(buffer, vim.fn.tempname() .. ".nu")
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { 'let value: int = "not an integer"' })
    vim.bo[buffer].filetype = "nu"
    vim.api.nvim_set_current_buf(buffer)

    local configuration = dofile(config_root .. "/after/lsp/nushell.lua")
    configuration.name = "nushell"
    configuration.root_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ":h")

    local identifier = assert(vim.lsp.start(configuration, { bufnr = buffer }))
    local received = vim.wait(10000, function()
      return #vim.diagnostic.get(buffer) > 0
    end, 25)

    vim.lsp.get_client_by_id(identifier):stop(true)

    assert.is_true(received, "Nushell did not publish diagnostics for an invalid type")
    assert.are.equal(vim.diagnostic.severity.ERROR, vim.diagnostic.get(buffer)[1].severity)

    vim.api.nvim_buf_delete(buffer, { force = true })
  end)
end)
