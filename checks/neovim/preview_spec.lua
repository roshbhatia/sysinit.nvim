local busted = require("plenary.busted")
local assert = require("luassert")

busted.describe("preview pane lifecycle", function()
  local executable
  local executable_field
  local original_parent
  local original_preview
  local original_terminal
  local temporary

  busted.before_each(function()
    executable = vim.fn.executable
    executable_field = rawget(vim.fn, "executable")
    original_parent = vim.env.WEZTERM_PANE
    original_preview = package.loaded["utils.glow_preview"]
    original_terminal = package.loaded["utils.wezterm_terminal"]
    temporary = vim.fn.tempname() .. ".md"
  end)

  busted.after_each(function()
    rawset(vim.fn, "executable", executable_field)
    vim.env.WEZTERM_PANE = original_parent
    package.loaded["utils.glow_preview"] = original_preview
    package.loaded["utils.wezterm_terminal"] = original_terminal
    pcall(vim.api.nvim_del_augroup_by_name, "SysinitPreview")
    vim.fn.delete(temporary)
  end)

  busted.it("keeps cleanup registered and routes every pane action through the bridge", function()
    local calls = {}
    local alive = false
    rawset(vim.fn, "executable", function(name)
      if name == "glow" or name == "wezterm" then
        return 1
      end
      return executable(name)
    end)
    package.loaded["utils.wezterm_terminal"] = {
      split = function(options)
        calls.split = options
        alive = true
        return "42"
      end,
      pane_alive = function(id)
        calls.alive = id
        return alive
      end,
      activate = function(id)
        calls.activate = id
      end,
      kill = function(id)
        calls.kill = id
        alive = false
      end,
    }
    package.loaded["utils.glow_preview"] = nil
    vim.env.WEZTERM_PANE = "7"
    vim.fn.writefile({ "# Preview" }, temporary)

    local result = require("utils.glow_preview").open(temporary)
    assert.is_true(result.ok)
    assert.are.equal("wezterm", result.surface)
    assert.are.equal(7, calls.split.parent)
    assert.are.equal(42, calls.split.percent)
    assert.are.equal("right", calls.split.side)
    assert.are.same({ "sh", "-c" }, vim.list_slice(calls.split.argv, 1, 2))
    assert.is_truthy(calls.split.argv[3]:find("glow", 1, true))
    assert.are.equal("7", tostring(calls.activate))
    assert.are.equal(2, #vim.api.nvim_get_autocmds({ group = "SysinitPreview" }))

    vim.api.nvim_exec_autocmds("VimLeavePre", { group = "SysinitPreview" })
    assert.are.equal("42", calls.kill)
  end)
end)
