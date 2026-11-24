local busted = require("plenary.busted")
local assert = require("luassert")

busted.describe("Diffview integration", function()
  local cwd
  local repository

  busted.before_each(function()
    cwd = vim.fn.getcwd()
    repository = vim.fn.tempname()
    vim.fn.mkdir(repository, "p")
  end)

  busted.after_each(function()
    pcall(vim.cmd.DiffviewClose)
    vim.fn.chdir(cwd)
    vim.fn.delete(repository, "rf")
  end)

  local function git(...)
    local result = vim.system({ "git", "-C", repository, ... }, { text = true }):wait()
    assert.are.equal(0, result.code, result.stderr)
  end

  busted.it("opens the native file panel and closes a working-tree diff", function()
    git("init", "--quiet")
    local file = repository .. "/tracked.txt"
    vim.fn.writefile({ "original" }, file)
    git("add", "tracked.txt")
    git(
      "-c",
      "user.name=Fixture",
      "-c",
      "user.email=fixture@example.invalid",
      "-c",
      "commit.gpgsign=false",
      "commit",
      "--quiet",
      "-m",
      "seed"
    )
    vim.fn.writefile({ "edited" }, file)
    vim.fn.chdir(repository)

    local spec = dofile(vim.env.SYSINIT_NVIM_CONFIG .. "/lua/plugins/diffview.lua")[1]
    require("diffview").setup(spec.opts)
    local tabs = #vim.api.nvim_list_tabpages()
    vim.cmd.DiffviewOpen()
    assert.is_true(vim.wait(2000, function()
      local panel = false
      local diffs = 0
      for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buffer = vim.api.nvim_win_get_buf(window)
        panel = panel or vim.bo[buffer].filetype == "DiffviewFiles"
        if vim.wo[window].diff then
          diffs = diffs + 1
        end
      end
      return panel and diffs == 2
    end))
    vim.cmd.DiffviewClose()
    assert.are.equal(tabs, #vim.api.nvim_list_tabpages())
  end)
end)
