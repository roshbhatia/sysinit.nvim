return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VimEnter",
    branch = "master",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "c",
          "comment",
          "css",
          "csv",
          "cue",
          "diff",
          "dockerfile",
          "git_config",
          "git_rebase",
          "gitattributes",
          "gitcommit",
          "gitignore",
          "go",
          "gomod",
          "gosum",
          "gotmpl",
          "gowork",
          "hcl",
          "helm",
          "html",
          "java",
          "javascript",
          "jinja",
          "jinja_inline",
          "jq",
          "jsdoc",
          "json",
          "lua",
          "luadoc",
          "luap",
          "markdown",
          "markdown_inline",
          "nix",
          "nu",
          "python",
          "query",
          "regex",
          "ruby",
          "rust",
          "scss",
          "terraform",
          "toml",
          "tsv",
          "typescript",
          "vim",
          "vimdoc",
          "xml",
          "yaml",
        },
        sync_install = false,
        auto_install = false,
        ignore_install = {
          "org",
        },
        modules = {},
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(lang, buf)
            -- Disable treesitter for very large files
            local line_count = vim.api.nvim_buf_line_count(buf)
            local file_size = vim.fn.getfsize(vim.api.nvim_buf_get_name(buf))

            -- Disable for files > 5000 lines or > 2MB
            if line_count > 5000 or file_size > 2 * 1024 * 1024 then
              return true
            end

            -- Disable for certain filetypes that don't benefit much
            local disable_ft = { "log", "txt", "csv", "json" }
            return vim.tbl_contains(disable_ft, lang)
          end,
        },
        rainbow = {
          enable = true,
          extended_mode = true,
          max_file_lines = nil,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "vvv",
            node_incremental = "vvi",
            scope_incremental = "vvI",
            node_decremental = "vvd",
          },
        },
        indent = {
          enable = true,
        },
        textobjects = {
          move = {
            enable = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]a"] = "@parameter.inner",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]C"] = "@class.outer",
              ["]A"] = "@parameter.inner",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[a"] = "@parameter.inner",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[C"] = "@class.outer",
              ["[A"] = "@parameter.inner",
            },
          },
        },
      })

    end,
  },
}
