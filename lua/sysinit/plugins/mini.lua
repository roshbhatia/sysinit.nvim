local function normalize_hex_color(hex)
  local color = hex:lower()

  if #color == 4 then
    local r, g, b = color:sub(2, 2), color:sub(3, 3), color:sub(4, 4)
    return ("#%s%s%s%s%s%s"):format(r, r, g, g, b, b)
  end

  if #color == 5 then
    local r, g, b = color:sub(2, 2), color:sub(3, 3), color:sub(4, 4)
    return ("#%s%s%s%s%s%s"):format(r, r, g, g, b, b)
  end

  if #color == 9 then
    return color:sub(1, 7)
  end

  return color
end

return {
  {
    "nvim-mini/mini.nvim",
    event = { "BufReadPost", "BufNewFile" },
    version = "*",
    config = function()
      local hipatterns = require("mini.hipatterns")

      local function hex_group(_, match)
        local normalized = normalize_hex_color(match)
        if not normalized:match("^#%x%x%x%x%x%x$") then
          return nil
        end
        return hipatterns.compute_hex_color_group(normalized, "bg")
      end

      require("mini.move").setup({
        mappings = {
          left = "<S-h>",
          right = "<S-l>",
          down = "<S-j>",
          up = "<S-k>",
        },
        options = {
          reindent_linewise = true,
        },
      })

      hipatterns.setup({
        highlighters = {
          fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
          hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
          todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
          note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
          hex_color = hipatterns.gen_highlighter.hex_color(),
          hex_color_short = { pattern = "#%x%x%x%f[%X]", group = hex_group },
          hex_color_short_alpha = { pattern = "#%x%x%x%x%f[%X]", group = hex_group },
          hex_color_alpha = { pattern = "#%x%x%x%x%x%x%x%x%f[%X]", group = hex_group },
        },
      })
    end,
  },
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
  },
  {
    "nvim-mini/mini.pairs",
    version = "*",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string" },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    },
  },
  {
    "nvim-mini/mini.surround",
    version = "*",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "q", -- Add surrounding in Normal and Visual modes
        delete = "qd", -- Delete surrounding
        find = "qf", -- Find surrounding (to the right)
        find_left = "qF", -- Find surrounding (to the left)
        highlight = "qh", -- Highlight surrounding
        replace = "qr", -- Replace surrounding
        update_n_lines = "qn", -- Update `n_lines`
        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    },
  },
  {
    "nvim-mini/mini.comment",
    event = "VeryLazy",
    version = "*",
  },
}
