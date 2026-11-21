local busted = require("plenary.busted")
local assert = require("luassert")

local config_root = assert(vim.env.SYSINIT_NVIM_CONFIG)
local missing = {}

local function map_for(maps, lhs)
  for _, map in ipairs(maps) do
    if map[2] == lhs then
      return map
    end
  end
end

local function run_git(cwd, ...)
  local command = { "git", "-C", cwd }
  vim.list_extend(command, { ... })
  local result = vim.system(command, { text = true }):wait()
  assert.are.equal(0, result.code, result.stderr or table.concat(command, " "))
end

local function buffer_with_filetype(filetype)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].filetype == filetype and vim.fn.bufwinid(bufnr) ~= -1 then
      return bufnr
    end
  end
end

local function buffer_map(bufnr, lhs)
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(bufnr, "n")) do
    if map.lhs == lhs then
      return map
    end
  end
end

local function diff_windows()
  local found = {}
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.wo[winid].diff then
      found[#found + 1] = winid
    end
  end
  return found
end

busted.describe("Diffview integration", function()
  local loaded
  local original_cwd
  local temporary

  busted.before_each(function()
    original_cwd = assert(vim.uv.cwd())
    temporary = nil
    loaded = {}
    for _, name in ipairs({
      "diffview",
      "diffview.actions",
      "utils.diffview_layout",
      "utils.diffview",
    }) do
      loaded[name] = package.loaded[name] == nil and missing or package.loaded[name]
    end
  end)

  busted.after_each(function()
    if temporary ~= nil then
      pcall(vim.cmd, "DiffviewClose")
      vim.fn.chdir(original_cwd)
      vim.fn.delete(temporary, "rf")
    end
    for name, module in pairs(loaded) do
      if module == missing then
        package.loaded[name] = nil
      else
        package.loaded[name] = module
      end
    end
  end)

  busted.it("keeps the lazy spec declarative", function()
    local calls = 0
    package.loaded["utils.diffview"] = {
      setup = function()
        calls = calls + 1
      end,
    }
    local specs = dofile(config_root .. "/lua/plugins/diffview.lua")
    specs[1].config()
    assert.are.equal(1, calls)
  end)

  busted.it("builds conflict maps by surface", function()
    local actions = {
      close = function() end,
      focus_files = function() end,
      toggle_files = function() end,
      conflict_choose = function(name)
        return "hunk:" .. name
      end,
      conflict_choose_all = function(name)
        return "file:" .. name
      end,
      scroll_view = function(distance)
        return "scroll:" .. distance
      end,
    }
    package.loaded["utils.diffview"] = nil
    local integration = require("utils.diffview")
    local view = integration.keymaps(actions, "both")
    local files = integration.keymaps(actions, "file", true)
    local history = integration.keymaps(actions, "none", true)

    assert.are.equal("hunk:ours", map_for(view, "<localleader>dco")[3])
    assert.are.equal("file:ours", map_for(view, "<localleader>dcO")[3])
    assert.is_nil(map_for(files, "<localleader>dco"))
    assert.are.equal("file:ours", map_for(files, "<localleader>dcO")[3])
    assert.is_nil(map_for(history, "<localleader>dco"))
    assert.is_nil(map_for(history, "<localleader>dcO"))
    assert.are.equal("scroll:0.5", map_for(files, "<C-d>")[3])
    assert.are.equal("scroll:-0.5", map_for(history, "<C-u>")[3])
  end)

  busted.it("configures Diffview and its layout once", function()
    local diffview_options
    local layout_calls = 0
    local actions = {
      close = function() end,
      focus_files = function() end,
      toggle_files = function() end,
      conflict_choose = function()
        return function() end
      end,
      conflict_choose_all = function()
        return function() end
      end,
      scroll_view = function()
        return function() end
      end,
    }

    package.loaded["diffview.actions"] = actions
    package.loaded["diffview"] = {
      setup = function(options)
        diffview_options = options
      end,
    }
    package.loaded["utils.diffview_layout"] = {
      file_panel = function() end,
      file_history_panel = function() end,
      setup = function()
        layout_calls = layout_calls + 1
      end,
    }
    package.loaded["utils.diffview"] = nil

    local integration = require("utils.diffview")
    integration.setup()
    integration.setup()
    assert.are.equal("tree", diffview_options.file_panel.listing_style)
    assert.are.equal(1, layout_calls)
  end)

  busted.it("moves the file panel below narrow diffs", function()
    local columns = vim.o.columns
    local lines = vim.o.lines
    package.loaded["utils.diffview_layout"] = nil
    local layout = require("utils.diffview_layout")

    vim.o.columns = 200
    vim.o.lines = 60
    assert.are.same({ type = "split", position = "left", width = 40 }, layout.file_panel())
    vim.o.columns = 120
    assert.are.same({ type = "split", position = "bottom", height = 14 }, layout.file_panel())

    vim.o.columns = columns
    vim.o.lines = lines
  end)

  busted.it("keeps panel shortcuts and synchronized scrolling in a real Diffview", function()
    temporary = vim.fn.tempname()
    vim.fn.mkdir(temporary, "p")
    run_git(temporary, "init", "--quiet")
    run_git(temporary, "config", "user.name", "editor check")
    run_git(temporary, "config", "user.email", "editor-check@localhost")
    run_git(temporary, "config", "commit.gpgsign", "false")
    local original = {}
    for line = 1, 120 do
      original[line] = "line " .. line
    end
    vim.fn.writefile(original, temporary .. "/tracked.txt")
    run_git(temporary, "add", "tracked.txt")
    run_git(temporary, "commit", "--quiet", "-m", "seed")
    local changed = vim.deepcopy(original)
    changed[60] = "changed line 60"
    vim.fn.writefile(changed, temporary .. "/tracked.txt")
    vim.fn.chdir(temporary)

    package.loaded["utils.diffview"] = nil
    require("utils.diffview").setup()
    vim.cmd("DiffviewOpen")

    local panel
    assert.is_true(vim.wait(2000, function()
      panel = buffer_with_filetype("DiffviewFiles")
      return panel ~= nil
    end))
    assert.are.equal("Close the diff", buffer_map(panel, "q").desc)
    assert.are.equal("Toggle the file panel", buffer_map(panel, ",db").desc)
    local scroll_down = buffer_map(panel, "<C-D>")
    assert.are.equal("Scroll the diff down", scroll_down.desc)

    local sources
    assert.is_true(vim.wait(2000, function()
      sources = diff_windows()
      return #sources == 2
    end))
    for _, winid in ipairs(sources) do
      assert.is_true(vim.wo[winid].scrollbind)
      assert.is_true(vim.wo[winid].cursorbind)
    end

    local before = vim.fn.line("w0", sources[1])
    scroll_down.callback()
    assert.is_true(vim.wait(1000, function()
      return vim.fn.line("w0", sources[1]) > before
    end))
    assert.are.equal(vim.fn.line("w0", sources[1]), vim.fn.line("w0", sources[2]))
  end)
end)
