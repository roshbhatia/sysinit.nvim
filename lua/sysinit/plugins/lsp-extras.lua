return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "b0o/SchemaStore.nvim",
    version = "*",
  },
  {
    "onsails/lspkind.nvim",
  },
  {
    "Chaitanyabsprip/fastaction.nvim",
    event = "LspAttach",
    opts = {
      keys = "fjdkslaghrueiwoncmv",
      dismiss_keys = { "j", "k", "<c-c>", "q" },
      register_ui_select = false,
    },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LSPAttach",
    config = function()
      local lsp_lines = require("lsp_lines")
      local original_hide = lsp_lines.hide
      local original_show = lsp_lines.show

      lsp_lines.hide = function()
        local ok, err = pcall(original_hide)
        if not ok and err and err:match("Invalid buffer id") then
          vim.notify("LSP Lines: Buffer no longer exists", vim.log.levels.WARN)
        elseif not ok then
          vim.notify("LSP Lines error: " .. tostring(err), vim.log.levels.ERROR)
        end
      end

      lsp_lines.show = function()
        local ok, err = pcall(original_show)
        if not ok and err and err:match("Invalid buffer id") then
          vim.notify("LSP Lines: Buffer no longer exists", vim.log.levels.WARN)
        elseif not ok then
          vim.notify("LSP Lines error: " .. tostring(err), vim.log.levels.ERROR)
        end
      end

      lsp_lines.setup()
    end,
    keys = function()
      return {
        {
          "<leader>cL",
          function()
            require("lsp_lines").toggle()
          end,
          desc = "Toggle lsp lines",
        },
      }
    end,
  },
  {
    "Fildo7525/pretty_hover",
    opts = {
      max_width = math.floor(vim.o.columns * 0.7),
      max_height = math.floor(vim.o.lines * 0.3),
    },
    keys = function()
      return {
        {
          "<S-k>",
          function()
            require("pretty_hover").hover()
          end,
          desc = "Hover documentation",
        },
      }
    end,
  },
}
