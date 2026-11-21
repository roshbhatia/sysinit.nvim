local M = {}

local configured = false

---@param actions table
---@param conflicts "none"|"hunk"|"file"|"both"
---@param panel? boolean
---@return table[]
function M.keymaps(actions, conflicts, panel)
  local maps = {
    { "n", "q", actions.close, { desc = "Close the diff" } },
    { "n", "<leader>e", false },
    { "n", "<leader>b", false },
    { "n", "<localleader>de", actions.focus_files, { desc = "Focus the file panel" } },
    { "n", "<localleader>db", actions.toggle_files, { desc = "Toggle the file panel" } },
  }
  if panel then
    maps[#maps + 1] = { "n", "<C-d>", actions.scroll_view(0.5), { desc = "Scroll the diff down" } }
    maps[#maps + 1] = { "n", "<C-u>", actions.scroll_view(-0.5), { desc = "Scroll the diff up" } }
  end
  local names = { o = "ours", t = "theirs", b = "base", a = "all" }
  for _, key in ipairs({ "o", "t", "b", "a" }) do
    local name = names[key]
    if conflicts == "hunk" or conflicts == "both" then
      maps[#maps + 1] = { "n", "<leader>c" .. key, false }
      maps[#maps + 1] = {
        "n",
        "<localleader>dc" .. key,
        actions.conflict_choose(name),
        { desc = "Take " .. name },
      }
    end
    if conflicts == "file" or conflicts == "both" then
      maps[#maps + 1] = { "n", "<leader>c" .. key:upper(), false }
      maps[#maps + 1] = {
        "n",
        "<localleader>dc" .. key:upper(),
        actions.conflict_choose_all(name),
        { desc = "Take " .. name .. " for the whole file" },
      }
    end
  end
  return maps
end

function M.setup()
  if configured then
    return
  end
  configured = true

  local actions = require("diffview.actions")
  local layout = require("utils.diffview_layout")

  require("diffview").setup({
    enhanced_diff_hl = true,
    show_help_hints = false,
    view = {
      merge_tool = { layout = "diff3_mixed" },
    },
    file_panel = {
      listing_style = "tree",
      win_config = layout.file_panel,
    },
    file_history_panel = {
      win_config = layout.file_history_panel,
    },
    keymaps = {
      view = M.keymaps(actions, "both"),
      file_panel = M.keymaps(actions, "file", true),
      file_history_panel = M.keymaps(actions, "none", true),
    },
  })

  layout.setup()
end

return M
