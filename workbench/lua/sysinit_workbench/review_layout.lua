local file_edges = { "left", "right", "top", "bottom", "auto" }
local split_directions = { left = "left", right = "right", top = "above", bottom = "below" }
local file_edge = "auto"

local M = {}
local configured

function M.setup()
  if configured then
    return
  end
  configured = true
  local ui = require("reviewr.ui")
  local last_edge
  ui.equalize = function()
    if not ui.is_open() then
      return
    end
    local diff, panel = ui.panes(), ui.files_panel()
    if not panel.win or not vim.api.nvim_win_is_valid(panel.win) then
      return
    end
    local cols, rows = vim.o.columns, vim.o.lines
    local edge = file_edge == "auto" and (cols >= 136 and "left" or "bottom") or file_edge
    local side = edge == "left" or edge == "right"
    local width = math.min(36, math.max(16, math.floor(cols * 0.22)))
    local stack = cols - (side and width or 0) < 100 and rows >= 22
    local diff_tab = vim.api.nvim_win_get_tabpage(diff.left_win)
    if diff_tab ~= vim.api.nvim_get_current_tabpage() then
      return
    end

    local left = vim.api.nvim_win_get_position(diff.left_win)
    local right = vim.api.nvim_win_get_position(diff.right_win)
    local move_diff = stack ~= (left[1] ~= right[1])
    if move_diff then
      vim.api.nvim_win_set_config(diff.right_win, { win = diff.left_win, split = stack and "below" or "right" })
    end
    if edge ~= last_edge or move_diff then
      vim.api.nvim_win_set_config(panel.win, { win = -1, split = split_directions[edge] })
    end
    last_edge = edge
    vim.wo[panel.win].winfixwidth = side
    vim.wo[panel.win].winfixheight = not side
    if side then
      vim.api.nvim_win_set_width(panel.win, width)
    else
      vim.api.nvim_win_set_height(panel.win, math.min(8, math.max(3, math.floor(rows * 0.19))))
    end
    if #vim.api.nvim_tabpage_list_wins(diff_tab) == 3 then
      local size = stack and vim.api.nvim_win_get_height or vim.api.nvim_win_get_width
      local resize = stack and vim.api.nvim_win_set_height or vim.api.nvim_win_set_width
      resize(diff.left_win, math.floor((size(diff.left_win) + size(diff.right_win)) / 2))
    end
  end
  vim.api.nvim_create_autocmd("TabEnter", {
    callback = function()
      ui.equalize()
    end,
  })
  local render = ui.open_files_panel
  ui.open_files_panel = function(files)
    local previous = ui.files_panel().win
    if not previous or not vim.api.nvim_win_is_valid(previous) then
      last_edge = nil
    end
    render(files)
  end
  local function place(edge)
    file_edge = edge
    ui.equalize()
  end
  vim.api.nvim_create_user_command("ReviewFiles", function(command)
    if not vim.tbl_contains(file_edges, command.args) then
      error("Expected left, right, top, bottom, or auto")
    end
    place(command.args)
  end, {
    nargs = 1,
    complete = function()
      return file_edges
    end,
  })
  local function cycle_edge()
    for index, edge in ipairs(file_edges) do
      if edge == file_edge then
        place(file_edges[index % #file_edges + 1])
        return
      end
    end
  end
  local keys = require("reviewr.keymaps")
  local install = keys.install
  keys.install = function(buf, options)
    install(buf, options)
    vim.keymap.set("n", "<LocalLeader>w", cycle_edge, { buffer = buf, desc = "Move review file tree" })
  end
  table.insert(keys.legend, {
    (vim.g.maplocalleader or "\\") .. "w",
    "move the file tree",
  })
end

return M
