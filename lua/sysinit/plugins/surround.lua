return {
  {
    "nvim-mini/mini.surround",
    version = "*",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "A",           -- Add surrounding in Normal and Visual modes ("append around")
        delete = "Ad",       -- Delete surrounding
        find = "Af",         -- Find surrounding (to the right)
        find_left = "AF",    -- Find surrounding (to the left)
        highlight = "Ah",    -- Highlight surrounding
        replace = "Ar",      -- Replace surrounding
        update_n_lines = "An", -- Update `n_lines`
        suffix_last = "l",   -- Suffix to search with "prev" method
        suffix_next = "n",   -- Suffix to search with "next" method
      },
    },
  },
}
