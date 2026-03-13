return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")

      wk.setup({
        preset = "helix",
        icons = {
          mappings = false,
          separator = " ",
        },
        notify = false,
        win = {
          border = "rounded",
        },
        layout = {
          spacing = 6,
          align = "center",
        },
      })

      wk.add({
        { "<leader>c", group = "Code" },
        { "<leader>cf", group = "Find (Code)" },
        { "<leader>d", group = "Diff" },
        { "<leader>e", group = "Explorer" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>gb", group = "Buffer" },
        { "<leader>gf", group = "Find (Git)" },
        { "<leader>gh", group = "Hunk" },
        { "<leader>j", group = "AI Agents" },
        { "<leader>k", group = "Avante" },
        { "<leader>m", group = "Marks" },
        { "<leader>q", group = "Force Quit" },
        { "<leader>r", group = "Debug" },
        { "<localleader>x", group = "Filetype Specific" },
        { "gr", group = "LSP" },
        { "]", group = "Next" },
        { "[", group = "Prev" },
        { "v<leader>", group = "Extras" },
        { "v<leader>c", group = "Code" },
        { "v<leader>g", group = "Git" },
        { "v<leader>j", group = "AI Agents" },
        { "vg", group = "Extras" },
        { "vgr", group = "Code" },
        { "vv", group = "AST" },
        { "vz", group = "Fold" },
      })
    end,
  },
}
