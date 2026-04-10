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
        layout = {
          spacing = 6,
          align = "center",
        },
      })

      wk.add({
        -- ── Top-level groups ─────────────────────────────────────────────────
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Diff" },
        { "<leader>e", group = "Explorer" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>j", group = "Agents" }, -- neph terminal agents
        { "<leader>q", group = "Force Quit" },
        { "<leader>r", group = "Debug" }, -- DAP only
        { "<leader>t", group = "Terminal" },

        -- ── Code subgroups ───────────────────────────────────────────────────
        { "<leader>cf", group = "Find" },

        -- ── Diff subgroups ───────────────────────────────────────────────────
        { "<leader>dr", group = "Review" },

        -- ── Git subgroups ────────────────────────────────────────────────────
        { "<leader>gb", group = "Buffer" },
        { "<leader>gf", group = "Find" },
        { "<leader>gh", group = "Hunk" },

        -- ── Navigation ───────────────────────────────────────────────────────
        { "]", group = "Next" },
        { "[", group = "Prev" },

        -- ── LSP (no leader) ──────────────────────────────────────────────────
        { "gr", group = "LSP" },

        -- ── Visual mode ──────────────────────────────────────────────────────
        { "v<leader>", group = "Extras" },
        { "v<leader>c", group = "Code" },
        { "v<leader>g", group = "Git" },
        { "v<leader>j", group = "Agents" },
        { "vg", group = "Extras" },
        { "vgr", group = "Code" },
        { "vv", group = "AST" },
        { "vz", group = "Fold" },
      })
    end,
  },
}
