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
    opts = function()
      local neoconf = require("neoconf")
      local defaults = {
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
        windows = {
          spinner = {
            thinking = { "󰟶", "󰟷" },
          },
          ask = {
            floating = true,
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          },
          edit = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          },
        },
        behaviour = {
          auto_apply_diff_after_generation = true,
          jump_result_buffer_on_finish = true,
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
            debug = "<leader>ktd",
            selection = "<leader>kts",
            suggestion = "<leader>kta",
            repomap = "<leader>ktr",
          },
          files = {
            add_current = "<leader>kFc",
            add_all_buffers = "<leader>kFa",
          },
          select_model = "<leader>k?",
          select_history = "<leader>kh",
        },
      }

      return vim.tbl_deep_extend("force", defaults, neoconf.get("avante") or {})
    end,
    config = function(_, opts)
      require("avante").setup(opts)

      vim.api.nvim_set_hl(0, "AvantePromptInput", { bg = "NONE", blend = 100 })

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
