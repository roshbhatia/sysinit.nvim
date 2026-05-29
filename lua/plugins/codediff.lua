return {
  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CodeDiff",
    config = function()
      require("codediff").setup({
        explorer = {
          position = "bottom",
          view_mode = "tree",
        },
        history = {
          position = "left",
        },
        keymaps = {
          view = {
            toggle_explorer = "<leader>dt",
          },
          conflict = {
            accept_incoming = "<leader>dt",
            accept_current = "<leader>dc",
            accept_both = "<leader>db",
            discard = "<leader>dx",
          },
        },
        diff = {
          compute_moves = true,
        },
      })

      local function clear_foldsign(buf)
        local ns = vim.api.nvim_get_namespaces()["nvim-foldsign"]
        if ns then
          vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        end
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeDiffOpen",
        callback = function()
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            vim.wo[win].foldcolumn = "0"
            vim.wo[win].signcolumn = "no"
            vim.wo[win].number = true
            vim.wo[win].relativenumber = false
            vim.wo[win].foldenable = false
            clear_foldsign(vim.api.nvim_win_get_buf(win))
          end
          vim.g.codediff_saved_showtabline = vim.o.showtabline
          vim.o.showtabline = 0
          -- prevent foldsign from re-drawing while diff is open
          require("nvim-foldsign").setup({ enabled = false })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeDiffClose",
        callback = function()
          if vim.g.codediff_saved_showtabline then
            vim.o.showtabline = vim.g.codediff_saved_showtabline
            vim.g.codediff_saved_showtabline = nil
          end
          require("nvim-foldsign").setup({ enabled = true })
        end,
      })
    end,
    keys = {
      {
        "<leader>dd",
        "<Cmd>CodeDiff<CR>",
        desc = "Open repo diff",
      },
      {
        "<leader>dH",
        "<Cmd>CodeDiff history<CR>",
        desc = "Open repo history",
      },
      {
        "<leader>dh",
        function()
          local filepath = vim.fn.expand("%")
          vim.cmd("CodeDiff history " .. filepath)
        end,
        desc = "Current file history",
      },
    },
  },
}
