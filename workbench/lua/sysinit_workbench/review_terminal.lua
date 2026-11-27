local function mux_cli(args)
  return vim.system(vim.list_extend({ "wezterm", "cli", "--no-auto-start" }, args)):wait(1500)
end

local function foreground_group(tty)
  if type(tty) ~= "string" or tty == "" then
    return nil
  end
  local result = vim.system({ "ps", "-t", tty:gsub("^/dev/", ""), "-o", "tpgid=" }):wait(1000)
  return result.code == 0 and (result.stdout or ""):match("^%s*([1-9]%d*)") or nil
end

local function open_review(range, direction)
  if vim.v.vim_did_enter == 0 then
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        vim.schedule(function()
          open_review(range, direction)
        end)
      end,
    })
    return
  end

  -- Resolve the adjacent pane in the editor's mux, whose IDs may differ
  -- from those in the GUI that requested the split.
  local pane = vim.env.WEZTERM_PANE
  local listed = mux_cli({ "list", "--format", "json" })
  local ok, panes = pcall(vim.json.decode, listed.stdout or "")
  local owner
  if pane and ok and type(panes) == "table" then
    local own = vim.iter(panes):find(function(candidate)
      return tostring(candidate.pane_id) == pane
    end)
    if own then
      local down = direction == "down"
      owner = vim.iter(panes):find(function(candidate)
        if candidate.tab_id ~= own.tab_id or candidate.pane_id == own.pane_id then
          return false
        end
        if down then
          return candidate.left_col == own.left_col and candidate.top_row + candidate.size.rows + 1 == own.top_row
        end
        return candidate.top_row == own.top_row and candidate.left_col + candidate.size.cols + 1 == own.left_col
      end)
    end
  end
  local tty = owner and owner.tty_name
  local group = foreground_group(tty)

  require("sysinit_workbench.review").open({
    range = range,
    standalone = true,
    owner = owner and tostring(owner.pane_id),
    available = function()
      return group ~= nil and foreground_group(tty) == group
    end,
  })
end

return { open = open_review }
