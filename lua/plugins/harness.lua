return {
  {
    name = "harness",
    dir = vim.fn.stdpath("config") .. "/lua/harness",
    lazy = false,
    dependencies = {
      "folke/snacks.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      require("harness.api").setup()
    end,
    keys = {
      { "<leader>jj", function() require("harness.api").toggle() end,         desc = "Harness: pick / toggle active agent" },
      { "<leader>ja", function() require("harness.api").ask() end,            desc = "Harness: ask",                       mode = { "n", "v" } },
      { "<leader>jc", function() require("harness.api").comment() end,        desc = "Harness: comment",                   mode = { "n", "v" } },
      { "<leader>jf", function() require("harness.api").fix() end,            desc = "Harness: fix diagnostics" },
      { "<leader>jr", function() require("harness.api").resend() end,         desc = "Harness: resend last prompt" },
      { "<leader>jx", function() require("harness.api").kill() end,           desc = "Harness: kill active session" },
      { "<leader>jX", function() require("harness.api").kill_and_pick() end,  desc = "Harness: kill and re-pick" },
      { "<leader>jb", function() require("harness.api").add_buffer() end,     desc = "Harness: add current buffer" },
      { "<leader>js", function() require("harness.api").send_selection() end, desc = "Harness: send selection",            mode = "v" },
    },
  },
}
