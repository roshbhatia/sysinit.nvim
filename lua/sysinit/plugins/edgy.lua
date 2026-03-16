return {
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>et",
        function()
          vim.cmd("Neotree toggle")
          vim.cmd("wincmd p")
        end,
        desc = "Toggle explorer tree",
      },
      {
        "<leader>ex",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Toggle diagnostics (Trouble)",
      },
      {
        "<leader>eg",
        function()
          require("grug-far").toggle_instance({
            instanceName = "far-global",
            staticTitle = "Global Search",
            prefills = {
              search = vim.fn.expand("<cword>"),
              filesFilter = "*",
            },
          })
        end,
        desc = "Toggle global search (Grug-far)",
      },
      {
        "<leader>eo",
        function()
          vim.cmd("Outline!")
        end,
        desc = "Toggle outline",
      },
      {
        "]e",
        function()
          require("edgy").next()
        end,
        desc = "Next sidebar",
      },
      {
        "[e",
        function()
          require("edgy").prev()
        end,
        desc = "Prev sidebar",
      },
    },
    opts = {
      animate = {
        enabled = false,
      },
      exit_when_last = true,
      keys = {
        ["q"] = function(win)
          win:hide()
        end,
        ["<c-q>"] = false,
        ["Q"] = false,
        ["]w"] = false,
        ["[w"] = false,
        ["]W"] = false,
        ["[W"] = false,
        ["<c-w>>"] = false,
        ["<c-w><lt>"] = false,
        ["<c-w>+"] = false,
        ["<c-w>-"] = false,
        ["<c-w>="] = false,
      },
      left = {
        {
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "filesystem"
          end,
          size = { width = 0.2585 },
        },
        {
          ft = "trouble",
          size = { width = 0.2625 },
          ---@diagnostic disable-next-line: unused-local
          filter = function(buf, win)
            return vim.w[win].trouble_type == nil or vim.w[win].trouble_type == ""
          end,
        },
        {
          ft = "grug-far",
          size = { width = 0.4 },
        },
      },
      right = {
        {
          ft = "help",
          size = { width = 0.5 },
          filter = function(buf)
            return vim.bo[buf].buftype == "help"
          end,
        },
        {
          ft = "Avante",
          size = { width = 0.3, height = 0.7 },
        },
        {
          ft = "AvanteSelectedFiles",
          size = { width = 0.3, height = 0.1 },
        },
        {
          ft = "AvanteInput",
          size = { width = 0.3, height = 0.2 },
        },
      },
    },
  },
}
