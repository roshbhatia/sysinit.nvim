local M = {}

local group
local preview = {}

local function owns_window()
  return preview.window
    and vim.api.nvim_win_is_valid(preview.window)
    and vim.api.nvim_win_get_buf(preview.window) == preview.buffer
end

local function ty(args)
  local result = vim.system(vim.list_extend({ "ty" }, args), { text = true }):wait(2500)
  return result.code == 0 and result.stdout or nil
end

local function close()
  if preview.pane then
    ty({ "pane", "close", preview.pane })
  end
  if owns_window() then
    vim.api.nvim_win_close(preview.window, true)
  end
  preview = {}
end

local function adjacent(path, focus)
  local parent = vim.env.WEZTERM_PANE
  if not parent or vim.fn.executable("ty") ~= 1 then
    return nil
  end
  local output = ty({
    "pane",
    "spawn",
    parent,
    "--direction",
    "right",
    "--percent",
    "42",
    "--cwd",
    vim.fs.dirname(path),
    "--",
    "glow",
    "--tui",
    "--",
    path,
  })
  if not output then
    return nil
  end
  local result = vim.json.decode(output)
  if focus == false then
    ty({ "pane", "focus", parent })
  end
  return tostring(result.pane_id)
end

local function split(path, glow, focus)
  local source = vim.api.nvim_get_current_win()
  vim.cmd("botright vsplit")
  local window = vim.api.nvim_get_current_win()
  if glow then
    vim.cmd.enew()
    vim.bo.bufhidden = "wipe"
    vim.fn.jobstart({ "glow", "--tui", "--", path }, { term = true })
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = 0 })
  else
    vim.cmd.edit({ args = { path } })
  end
  if focus == false then
    vim.api.nvim_set_current_win(source)
  end
  return window
end

function M.open(path, opts)
  M.setup()
  local full = vim.fn.fnamemodify(path, ":p")
  if vim.fn.filereadable(full) ~= 1 then
    return { ok = false, error = "no such file: " .. full }
  end
  close()
  local focus = (opts or {}).focus
  local glow = vim.fn.executable("glow") == 1
  preview.path = full
  preview.pane = glow and adjacent(full, focus) or nil
  if not preview.pane then
    preview.window = split(full, glow, focus)
    preview.buffer = vim.api.nvim_win_get_buf(preview.window)
  end
  return {
    ok = true,
    renderer = glow and "glow" or "buffer",
    surface = preview.pane and "wezterm" or "split",
  }
end

function M.setup()
  if group then
    return
  end
  group = vim.api.nvim_create_augroup("SysinitPreview", { clear = true })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if preview.pane then
        ty({ "pane", "close", preview.pane })
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(event)
      if vim.api.nvim_buf_get_name(event.buf) ~= preview.path then
        return
      end
      local visible = owns_window()
      if preview.pane then
        local output = ty({ "panes" })
        local panes = output and vim.json.decode(output).panes or {}
        visible = vim.iter(panes):any(function(pane)
          return tostring(pane.pane_id) == preview.pane
        end)
      end
      if visible then
        M.open(preview.path, { focus = false })
      end
    end,
  })
end

return M
