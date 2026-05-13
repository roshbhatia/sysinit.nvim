return {
  {
    "tamton-aquib/staline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
      local hl_utils = require("utils.highlight")
      local get_fg = hl_utils.get_fg

      local function get_format_status()
        if vim.g.disable_autoformat or vim.b.disable_autoformat then
          return "󰉥 "
        end
        return ""
      end

      local function harness_active()
        local name = vim.g.harness_active
        if not name or name == "" then
          return ""
        end
        local label = name
        local ok, reg = pcall(require, "harness.registry")
        if ok then
          local adapter = reg.get_by_name(name)
          if adapter and adapter.label then
            label = adapter.label
          end
        end
        return "  " .. label .. " "
      end

      require("staline").setup({
        sections = {
          left = { "mode", "branch", "file_name" },
          mid = { harness_active, get_format_status },
          right = { "file_size", "line_column" },
        },
        defaults = {
          inactive_color = get_fg("Normal"),
          expand_null_ls = false,
          line_column = ":%c [%l/%L]",
          file_size_suffix = true,
          branch_symbol = " ",
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

      vim.defer_fn(function()
        vim.cmd("redrawstatus!")
      end, 0)
    end,
  },
}
