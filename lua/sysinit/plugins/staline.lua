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

      local function lsp_ai_model()
        -- Check if lsp_ai is attached to current buffer
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "lsp_ai" })
        
        if #clients > 0 and vim.g.lsp_ai_model then
          -- Show compact model name (remove version suffix)
          local model = vim.g.lsp_ai_model
          local short_name = model:match("^([^:]+)") or model
          return " " .. short_name .. " "
        end
        return ""
      end

      require("staline").setup({
        sections = {
          left = { "mode", "branch", "file_name", neph_status, lsp_ai_model, copilot_status },
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
    end,
  },
}
