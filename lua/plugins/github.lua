return {
  {
    "pwntester/octo.nvim",
    dir = assert(vim.env.SYSINIT_NVIM_OCTO, "The Nix-managed Octo plugin path is missing"),
    cmd = { "Octo", "PRReview" },
    keys = function()
      return require("utils.github_review").keys()
    end,
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("utils.github_review").setup()
    end,
  },
}
