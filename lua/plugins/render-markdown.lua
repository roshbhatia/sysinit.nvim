return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preset = "obsidian",
      file_types = { "markdown" },
      completions = { blink = { enabled = true } },
      sign = {
        enabled = false,
      },
    },
  },
}
