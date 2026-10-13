return {
  {
    "emrearmagan/atlas.nvim",
    cmd = "Atlas",
    dependencies = { "nvim-tree/nvim-web-devicons", "folke/snacks.nvim" },
    opts = {
      ui = { picker = "snacks" },
      providers = { github = {} },
    },
    keys = {
      { "<leader>ar", "<cmd>Atlas review<cr>", desc = "Review pull request" },
      { "<leader>ap", "<cmd>Atlas pulls github<cr>", desc = "GitHub pull requests" },
      { "<leader>ai", "<cmd>Atlas issues github<cr>", desc = "GitHub issues" },
      { "<leader>ab", "<cmd>Atlas browse .<cr>", desc = "Browse repository" },
      { "<leader>ac", "<cmd>Atlas pipelines .<cr>", desc = "Branch checks" },
      { "<leader>an", "<cmd>Atlas notes<cr>", desc = "Review notes" },
      { "<leader>as", "<cmd>Atlas search github<cr>", desc = "Search GitHub" },
    },
  },
}
