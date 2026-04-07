local diff_review = require("sysinit.utils.diff_review")

return {
  {
    -- virtual plugin — no remote source, just keymaps wired through lazy
    dir = vim.fn.stdpath("config"),
    name = "diff-review",
    lazy = false,
    dependencies = {
      "nickjvandyke/opencode.nvim",
      "folke/snacks.nvim",
      "lewis6991/gitsigns.nvim",
    },
    config = function()
      diff_review.setup({
        default_provider = "opencode",
      })
    end,
    keys = {
      -- Pickers
      {
        "<leader>drr",
        function()
          diff_review.picker_head()
        end,
        desc = "Diff Review: Picker - working tree",
      },
      {
        "<leader>drs",
        function()
          diff_review.picker_staged()
        end,
        desc = "Diff Review: Picker - staged",
      },
      {
        "<leader>drf",
        function()
          diff_review.picker_branch()
        end,
        desc = "Diff Review: Picker - branch",
      },

      -- AI review
      {
        "<leader>dra",
        function()
          diff_review.review_head()
        end,
        desc = "Diff Review: AI - uncommitted (HEAD)",
      },
      {
        "<leader>drS",
        function()
          diff_review.review_staged()
        end,
        desc = "Diff Review: AI - staged",
      },
      {
        "<leader>drb",
        function()
          diff_review.review_branch()
        end,
        desc = "Diff Review: AI - branch",
      },
      {
        "<leader>drF",
        function()
          diff_review.review_file()
        end,
        desc = "Diff Review: AI - current file",
      },
      {
        "<leader>drh",
        function()
          diff_review.review_hunk()
        end,
        desc = "Diff Review: AI - current hunk",
      },
    },
  },
}
