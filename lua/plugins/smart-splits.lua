local function set_user_var(name, value)
  local seq = ("\27]1337;SetUserVar=%s=%s\7"):format(name, vim.base64.encode(value))
  vim.api.nvim_ui_send(seq)
end

local nav_seq = 0

local function keep(resize)
  return function()
    resize()
    pcall(function()
      require("bufresize").register()
    end)
  end
end

local function ask_wezterm_to_move(direction)
  nav_seq = nav_seq + 1
  set_user_var("SYSINIT_NAV", direction .. ":" .. nav_seq)
end

local function announce_nvim(present)
  set_user_var("IS_NVIM", present and "true" or "false")
end

return {
  {
    "mrjones2014/smart-splits.nvim",
    event = "VeryLazy",
    init = function()
      if vim.env.TERM_PROGRAM == "WezTerm" or vim.env.WEZTERM_PANE then
        vim.g.smart_splits_multiplexer_integration = false
      end
      announce_nvim(true)
      vim.api.nvim_create_autocmd({ "UIEnter", "VimResume" }, {
        callback = function()
          announce_nvim(true)
        end,
      })
      vim.api.nvim_create_autocmd({ "VimSuspend", "VimLeavePre" }, {
        callback = function()
          announce_nvim(false)
        end,
      })
    end,
    config = function()
      local ft = require("utils.filetypes")
      local smart_splits = require("smart-splits")
      local function at_edge(ctx)
        ask_wezterm_to_move(ctx.direction)
      end
      local options = {
        ignored_filetypes = ft.sidebar_filetypes,
        ignored_buftypes = ft.utility_buftypes,
      }
      if smart_splits.PROTOCOL_VERSION then
        options.swap = { move_cursor = true }
        options.move = { at_edge = at_edge }
        options.resize = { amount = 3 }
      else
        options.cursor_follows_swapped_bufs = true
        options.at_edge = at_edge
        options.default_amount = 3
      end
      smart_splits.setup(options)
    end,
    keys = function()
      local smart_splits = require("smart-splits")
      return {
        {
          "<C-h>",
          function()
            smart_splits.move_cursor_left()
          end,
          mode = { "n", "i", "v", "t" },
          desc = "Move to left pane",
        },
        {
          "<C-j>",
          function()
            smart_splits.move_cursor_down()
          end,
          mode = { "n", "i", "v", "t" },
          desc = "Move to bottom pane",
        },
        {
          "<C-k>",
          function()
            smart_splits.move_cursor_up()
          end,
          mode = { "n", "i", "v", "t" },
          desc = "Move to top pane",
        },
        {
          "<C-l>",
          function()
            smart_splits.move_cursor_right()
          end,
          mode = { "n", "i", "v", "t" },
          desc = "Move to right pane",
        },
        {
          "<C-S-h>",
          keep(smart_splits.resize_left),
          mode = { "n", "i", "v", "t" },
          desc = "Decrease pane width",
        },
        {
          "<C-S-j>",
          keep(smart_splits.resize_down),
          mode = { "n", "i", "v", "t" },
          desc = "Decrease pane height",
        },
        {
          "<C-S-k>",
          keep(smart_splits.resize_up),
          mode = { "n", "i", "v", "t" },
          desc = "Increase pane height",
        },
        {
          "<C-S-l>",
          keep(smart_splits.resize_right),
          mode = { "n", "i", "v", "t" },
          desc = "Increase pane width",
        },
      }
    end,
  },
}
