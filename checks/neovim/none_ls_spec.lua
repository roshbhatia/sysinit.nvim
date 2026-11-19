local busted = require("plenary.busted")
local assert = require("luassert")

busted.describe("none-ls diagnostics", function()
  busted.it("creates its temporary directory and runs Deadnix", function()
    vim.opt.runtimepath:prepend(assert(vim.env.SYSINIT_NVIM_NONE_LS))

    local specification = dofile(vim.env.SYSINIT_NVIM_CONFIG .. "/lua/plugins/none-ls.lua")
    specification[1].config()

    assert.are.equal(1, vim.fn.isdirectory(vim.fn.stdpath("cache") .. "/null-ls"))

    local file = vim.fn.tempname() .. ".nix"
    vim.fn.writefile({ "{ unused }: 1" }, file)
    vim.cmd.edit(vim.fn.fnameescape(file))

    local buffer = vim.api.nvim_get_current_buf()
    vim.bo[buffer].filetype = "nix"
    local received = vim.wait(10000, function()
      for _, diagnostic in ipairs(vim.diagnostic.get(buffer)) do
        if diagnostic.source == "deadnix" then
          return true
        end
      end
      return false
    end, 25)

    require("null-ls").disable("deadnix")
    vim.api.nvim_buf_delete(buffer, { force = true })
    vim.fn.delete(file)

    assert.is_true(received, "Deadnix did not publish diagnostics through none-ls")
  end)
end)
