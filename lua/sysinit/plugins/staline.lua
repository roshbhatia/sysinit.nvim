return {
  {
    "tamton-aquib/staline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      local hl_utils = require("sysinit.utils.highlight")
      local get_fg = hl_utils.get_fg

      -- Helper to show format disabled icon only when relevant
      local function get_format_status()
        if vim.g.disable_autoformat or vim.b.disable_autoformat then
          return "󰉥 "
        end
        return ""
      end

      local function copilot_status()
        local ok, status = pcall(function()
          return require("sidekick").get_status()
        end)

        if not ok then
          return ""
        end

        if status then
          if status.kind == "Error" then
            return " "
          elseif status.busy then
            return " "
          else
            return " "
          end
        end
        return ""
      end

      local function neph_status()
        if vim.g.neph_connected then
          return "󰞇 "
        end
        return ""
      end

      require("staline").setup({
        sections = {
          left = { "mode", "branch", "file_name", neph_status, copilot_status },
          mid = {},
          right = { get_format_status, "lsp", "lsp_name", "file_size", "line_column" },
        },
        defaults = {
          inactive_color = get_fg("Normal"),
          expand_null_ls = false,
          line_column = ":%c [%l/%L]",
          lsp_client_symbol = "󰘧 ",
          lsp_client_character_length = 16,
          file_size_suffix = true,
          branch_symbol = " ",
        },
        mode_colors = {
          n = get_fg("Normal"),
          i = get_fg("String"),
          c = get_fg("Special"),
          v = get_fg("Statement"),
          V = get_fg("Statement"),
          [""] = get_fg("Statement"),
          R = get_fg("Constant"),
          r = get_fg("Constant"),
          s = get_fg("Type"),
          S = get_fg("Type"),
          t = get_fg("Directory"),
          ic = get_fg("String"),
          Rc = get_fg("Constant"),
          cv = get_fg("Special"),
        },
        mode_icons = {
          n = "NORMAL",
          i = "INSERT",
          c = "COMMAND",
          v = "VISUAL",
          V = "V-LINE",
          [""] = "V-BLOCK",
          R = "REPLACE",
          r = "REPLACE",
          s = "SELECT",
          S = "S-LINE",
          t = "TERMINAL",
          ic = "INSERT",
          Rc = "REPLACE",
          cv = "VIM EX",
        },
      })

      -- VeryLazy fires after the initial buffer's BufEnter/BufWinEnter events
      -- have already run, so staline never gets its first draw. Force it.
      vim.defer_fn(function()
        vim.cmd("redrawstatus!")
      end, 0)
    end,
  },
}
