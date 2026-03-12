return {
  {
    "yetone/avante.nvim",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      { "Kaiser-Yang/blink-cmp-avante", lazy = true },
    },
    build = "make",
    event = "VeryLazy",
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      instructions_file = "AGENTS.md",
      provider = "copilot",
      input = {
        provider = "snacks",
        provider_opts = {
          title = "Avante Input",
          icon = " ",
        },
      },
      selector = {
        provider = "snacks",
        provider_opts = {},
      },
      file_selector = {
        provider = "snacks",
        provider_opts = {},
      },
      mappings = {
        submit = {
          normal = "<CR>",
          insert = "<S-CR>",
        },
        suggestion = {
          accept = "<C-CR>",
          next = "<C-n>",
          prev = "<C-p>",
          dismiss = "<Esc>",
        },
        ask = "<leader>ka",
        new_ask = "<leader>kn",
        zen_mode = "<leader>kz",
        edit = "<leader>ke",
        refresh = "<leader>kr",
        focus = "<leader>kf",
        stop = "<leader>kS",
        toggle = {
          default = "<leader>kk",
          debug = "<leader>kd",
          selection = "<leader>kC",
          suggestion = "<leader>ks",
          repomap = "<leader>kR",
        },
        files = {
          add_current = "<leader>kc",
          add_all_buffers = "<leader>kB",
        },
        select_model = "<leader>k?",
        select_history = "<leader>kh",
      },
    },
    config = function(_, opts)
      require("avante").setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "Avante",
          "AvanteInput",
          "AvanteSelectedFiles",
        },
        callback = function()
          vim.opt_local.foldcolumn = "0"
          vim.opt_local.foldexpr = "0"
        end,
        desc = "Hide foldcolumn in Avante buffers",
      })
    end,
  },
}
