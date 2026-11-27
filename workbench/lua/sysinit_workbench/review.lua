local M = {}
local index

local function git(args, env)
  return vim.system(vim.list_extend({ "git" }, args), { env = env }):wait()
end

local function prepare_index()
  local env = { GIT_INDEX_FILE = index.temporary }
  vim.uv.fs_unlink(index.temporary)
  if vim.uv.fs_stat(index.source) then
    assert(vim.uv.fs_copyfile(index.source, index.temporary))
  end
  local untracked = git({ "ls-files", "--others", "--exclude-standard", "-z" }, env)
  assert(untracked.code == 0, untracked.stderr)
  local files = vim.split(untracked.stdout, "\0", { plain = true, trimempty = true })
  if #files > 0 then
    local added = git(vim.list_extend({ "--literal-pathspecs", "add", "--intent-to-add", "--" }, files), env)
    assert(added.code == 0, added.stderr)
  end
  vim.env.GIT_INDEX_FILE = index.temporary
end

local function setup_standalone(reviewr, options)
  local resolved = git({ "rev-parse", "--path-format=absolute", "--git-path", "index" })
  assert(resolved.code == 0, resolved.stderr)
  local directory = vim.fn.tempname()
  assert(vim.fn.mkdir(directory, "", 448) == 1)
  index = { source = vim.trim(resolved.stdout), temporary = directory .. "/index" }
  vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    callback = function()
      vim.fn.delete(directory, "rf")
    end,
  })
  prepare_index()
  local refresh = reviewr.refresh
  reviewr.refresh = function()
    prepare_index()
    return refresh()
  end
  local mark_turn = reviewr.mark_turn
  reviewr.mark_turn = function(opts)
    prepare_index()
    return mark_turn(opts)
  end

  local transport = require("reviewr.transport")
  local detect = transport.detect
  transport.detect = function(repo)
    if not options.owner or (options.available and not options.available()) then
      return {}
    end
    return vim.tbl_filter(function(candidate)
      return candidate.transport == "wezterm" and candidate.id == options.owner
    end, detect(repo))
  end
  vim.g.reviewr_standalone = true
end

function M.open(options)
  options = options or {}
  require("sysinit_workbench.review_layout").setup()
  local reviewr = require("reviewr")
  reviewr.setup({ send_mode = "queue", baseline_trigger = "manual" })
  local range = options.range and { options.range[1], options.range[2], "turn" }
  if options.standalone and not index then
    setup_standalone(reviewr, options)
  end

  local opened = reviewr.open(range)
  if opened and vim.g.reviewr_standalone then
    vim.g.sysinit_review_ready = 1
  end
  return opened
end

function M.refresh()
  return require("reviewr").refresh() and 1 or 0
end

function M.select(refresh, range)
  local ui = require("reviewr.ui")
  if not ui.is_open() then
    return 0
  end
  ui.focus_tab()
  local state = require("reviewr.state").get()
  if range then
    if state.base_ref ~= range[1] or state.head_ref ~= range[2] then
      require("reviewr").open({ range[1], range[2], "turn" })
    end
  elseif refresh then
    if state.head_ref and state.scope.name == "turn" then
      require("reviewr").set_scope("uncommitted")
    end
    if M.refresh() ~= 1 then
      return 0
    end
  end
  local review_tab = vim.api.nvim_win_get_tabpage(ui.panes().right_win)
  return vim.api.nvim_get_current_tabpage() == review_tab and 1 or 0
end

return M
