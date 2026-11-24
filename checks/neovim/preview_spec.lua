local busted = require("plenary.busted")
local assert = require("luassert")

busted.describe("preview pane lifecycle", function()
  local executable
  local executable_field
  local original_parent
  local original_preview
  local original_system
  local temporary

  busted.before_each(function()
    executable = vim.fn.executable
    executable_field = rawget(vim.fn, "executable")
    original_parent = vim.env.WEZTERM_PANE
    original_preview = package.loaded["utils.glow_preview"]
    original_system = vim.system
    package.loaded["utils.glow_preview"] = nil
    temporary = vim.fn.tempname() .. " preview.md"
    vim.fn.writefile({ "# Preview" }, temporary)
  end)

  busted.after_each(function()
    rawset(vim.fn, "executable", executable_field)
    vim.env.WEZTERM_PANE = original_parent
    vim.system = original_system
    package.loaded["utils.glow_preview"] = original_preview
    pcall(vim.api.nvim_del_augroup_by_name, "SysinitPreview")
    vim.fn.delete(temporary)
  end)

  busted.it("uses ty and an explicit pane ID for terminal placement and cleanup", function()
    local calls = {}
    rawset(vim.fn, "executable", function(name)
      return (name == "glow" or name == "ty") and 1 or executable(name)
    end)
    vim.system = function(argv)
      calls[#calls + 1] = argv
      return {
        wait = function()
          return { code = 0, stdout = '{"pane_id":42}' }
        end,
      }
    end
    vim.env.WEZTERM_PANE = "7"

    local result = require("utils.glow_preview").open(temporary, { focus = false })
    assert.is_true(result.ok)
    assert.are.equal("wezterm", result.surface)
    assert.are.same({ "ty", "pane", "spawn", "7" }, vim.list_slice(calls[1], 1, 4))
    assert.are.same({ "glow", "--tui", "--", temporary }, vim.list_slice(calls[1], #calls[1] - 3))
    assert.are.same({ "ty", "pane", "focus", "7" }, calls[2])

    vim.api.nvim_exec_autocmds("VimLeavePre", { group = "SysinitPreview" })
    assert.are.same({ "ty", "pane", "close", "42" }, calls[3])
  end)
end)
