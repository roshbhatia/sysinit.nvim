return {
  {
    "pwntester/octo.nvim",
    dir = assert(vim.env.SYSINIT_NVIM_OCTO, "The Nix-managed Octo plugin path is missing"),
    cmd = { "Octo", "PRReview" },
    keys = function()
      return require("harness.github").keys()
    end,
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("harness.github").setup()
    end,
  },
}
