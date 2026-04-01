local terminal = require("sysinit.utils.terminal")
local ls_colors = require("sysinit.utils.ls_colors")
local palette_builder = require("sysinit.utils.palette")

local SYNTAX_STYLES = {
  comments = { "italic" },
  conditionals = { "italic" },
  loops = { "bold" },
  functions = { "bold" },
  keywords = { "bold" },
  strings = { "italic" },
  variables = {},
  numbers = { "bold" },
  booleans = { "bold", "italic" },
  properties = { "italic" },
  types = { "bold" },
  operators = { "bold" },
}

-- Groups whose background gets cleared in transparent mode.
local TRANSPARENT_GROUPS = {
  "BlinkCmpDoc",
  "BlinkCmpDocBorder",
  "BlinkCmpMenu",
  "BlinkCmpMenuBorder",
  "BlinkCmpSignatureHelp",
  "BlinkCmpSignatureHelpBorder",
  "ColorColumn",
  "CursorColumn",
  "DropBarCurrentContext",
  "DropBarIconKindDefault",
  "DropBarIconKindDefaultNC",
  "DropBarMenuFloatBorder",
  "DropBarMenuNormalFloat",
  "FloatBorder",
  "FloatTitle",
  "FoldColumn",
  "GitSignsAddLnInline",
  "GitSignsAddPreview",
  "GitSignsChangeLnInline",
  "GitSignsDeleteLnInline",
  "GitSignsDeletePreview",
  "GitSignsDeleteVirtLn",
  "GitSignsStagedAdd",
  "GitSignsStagedAddCul",
  "GitSignsStagedAddLn",
  "GitSignsStagedAddNr",
  "GitSignsStagedChange",
  "GitSignsStagedChangeCul",
  "GitSignsStagedChangeLn",
  "GitSignsStagedChangeNr",
  "GitSignsStagedDelete",
  "GitSignsStagedDeleteCul",
  "GitSignsStagedDeleteLn",
  "GitSignsStagedDeleteNr",
  "GitSignsStagedTopdelete",
  "GitSignsStagedTopdeleteCul",
  "GitSignsStagedTopdeleteNr",
  "GitSignsStagedUntracked",
  "GitSignsStagedUntrackedCul",
  "GitSignsStagedUntrackedLn",
  "GitSignsStagedUntrackedNr",
  "GitSignsVirtLnum",
  "LazyNormal",
  "LineNr",
  "LineNrAbove",
  "LineNrBelow",
  "MsgSeparator",
  "NeoTreeGitAdded",
  "NeoTreeGitDeleted",
  "NeoTreeGitModified",
  "NeoTreeGitRenamed",
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "NeoTreeEndOfBuffer",
  "NeoTreeWinSeparator",
  "Normal",
  "NormalFloat",
  "NormalNC",
  "Pmenu",
  "PmenuBorder",
  "PmenuSbar",
  "PmenuThumb",
  "SignColumn",
  "StatusLine",
  "StatusLineNC",
  "StatusLineTerm",
  "StatusLineTermNC",
  "TabLine",
  "TabLineFill",
  "TreesitterContext",
  "TreesitterContextLineNumber",
  "WhichKeyBorder",
  "WhichKeyFloat",
  "WilderGradient1",
  "WilderGradient2",
  "WilderGradient3",
  "WilderGradient4",
  "WilderSeparator",
  "WilderSpinner",
  "WinBar",
  "WinBarNC",
  "WinSeparator",
}

local HIGHLIGHT_OVERRIDES = {
  DiagnosticError = { link = "ErrorMsg" },
  DiagnosticHint = { link = "Comment" },
  DiagnosticInfo = { link = "Identifier" },
  DiagnosticOk = { link = "Question" },
  DiagnosticWarn = { link = "WarningMsg" },
  DiagnosticVirtualTextError = { link = "DiagnosticError" },
  DiagnosticVirtualTextWarn = { link = "DiagnosticWarn" },
  DiagnosticVirtualTextInfo = { link = "DiagnosticInfo" },
  DiagnosticVirtualTextHint = { link = "DiagnosticHint" },
  ["@constant.builtin"] = { link = "Special" },
  ["@constructor"] = { link = "Typedef" },
  ["@function.builtin"] = { link = "Special" },
  ["@markup.heading"] = { link = "Title" },
  ["@markup.link.label"] = { link = "Special" },
  ["@markup.raw"] = { link = "String" },
  ["@module"] = { link = "Include" },
  ["@string.special.url"] = { link = "Underlined" },
  ["@variable"] = { link = "Identifier" },
  ["@variable.builtin"] = { link = "Special" },
  ["@variable.member"] = { link = "Identifier" },
  ["@variable.parameter"] = { link = "Identifier" },
}

-- Sync phase: parse LS_COLORS, detect transparency, build palette
local ls_data = ls_colors.parse()
local ls_palette = ls_colors.extract_palette(ls_data)
local transparent = terminal.is_transparent()

-- Build initial palette (terminal colours not yet available).
-- Returns nil when there is no colour data at all.
local initial_palette = palette_builder.build({}, ls_palette)

-- Comprehensive neogit highlight overrides.
-- Catppuccin's built-in neogit integration is incomplete and uses surface0 for
-- diff context backgrounds, which maps to near-black with terminal-derived palettes
-- and creates the "black bar" effect. We take full ownership here.
local function neogit_highlights(c)
  local U = require("catppuccin.utils.colors")
  return {
    -- Diff context: match normal buffer bg (no black bars)
    NeogitDiffContext              = { bg = c.base },
    NeogitDiffContextHighlight     = { bg = c.surface0 },
    NeogitDiffContextCursor        = { bg = c.base },

    -- Diff additions
    NeogitDiffAdd                  = { bg = U.darken(c.green, 0.10, c.base),  fg = U.darken(c.green, 0.80, c.base) },
    NeogitDiffAddHighlight         = { bg = U.darken(c.green, 0.25, c.base),  fg = c.green },
    NeogitDiffAddCursor            = { bg = c.surface0,                        fg = c.green },
    NeogitDiffAdditions            = { fg = U.darken(c.green, 0.60, c.base) },

    -- Diff deletions
    NeogitDiffDelete               = { bg = U.darken(c.red, 0.10, c.base),    fg = U.darken(c.red, 0.80, c.base) },
    NeogitDiffDeleteHighlight      = { bg = U.darken(c.red, 0.25, c.base),    fg = c.red },
    NeogitDiffDeleteCursor         = { bg = c.surface0,                        fg = c.red },
    NeogitDiffDeletions            = { fg = U.darken(c.red, 0.60, c.base) },

    -- Hunk headers
    NeogitHunkHeader               = { bg = U.darken(c.blue, 0.12, c.base),   fg = U.darken(c.blue, 0.55, c.base), bold = true },
    NeogitHunkHeaderHighlight      = { bg = U.darken(c.blue, 0.28, c.base),   fg = c.blue,                         bold = true },
    NeogitHunkHeaderCursor         = { bg = U.darken(c.blue, 0.28, c.base),   fg = c.blue,                         bold = true },

    -- Merge hunk headers
    NeogitHunkMergeHeader          = { bg = U.darken(c.teal, 0.12, c.base),   fg = U.darken(c.teal, 0.55, c.base), bold = true },
    NeogitHunkMergeHeaderHighlight = { bg = U.darken(c.teal, 0.28, c.base),   fg = c.teal,                         bold = true },
    NeogitHunkMergeHeaderCursor    = { bg = U.darken(c.teal, 0.28, c.base),   fg = c.teal,                         bold = true },

    -- Diff file headers
    NeogitDiffHeader               = { bg = c.base,    fg = c.blue,  bold = true },
    NeogitDiffHeaderHighlight      = { bg = c.base,    fg = c.peach, bold = true },

    -- Normal / float surfaces (keep them transparent so window bg shows through)
    NeogitNormal                   = { link = "Normal" },
    NeogitNormalFloat              = { link = "NormalFloat" },
    NeogitFloatBorder              = { link = "FloatBorder" },
    NeogitSignColumn               = { fg = "NONE", bg = "NONE" },
    NeogitCursorLine               = { link = "CursorLine" },
    NeogitCursorLineNr             = { link = "CursorLineNr" },
    NeogitWinSeparator             = { link = "WinSeparator" },

    -- Section headers / commit view
    NeogitSectionHeader            = { fg = c.mauve,   bold = true },
    NeogitCommitViewHeader         = { bg = U.darken(c.blue, 0.30, c.base), fg = U.lighten(c.blue, 0.80, c.text), bold = true },

    -- Fold marker: fully transparent so it never creates a black bar
    NeogitFold                     = { fg = "NONE", bg = "NONE" },

    -- Change-type labels
    NeogitChangeModified           = { fg = c.blue,    bold = true },
    NeogitChangeDeleted            = { fg = c.red,     bold = true },
    NeogitChangeAdded              = { fg = c.green,   bold = true },
    NeogitChangeRenamed            = { fg = c.mauve,   bold = true },
    NeogitChangeUpdated            = { fg = c.peach,   bold = true },
    NeogitChangeCopied             = { fg = c.pink,    bold = true },
    NeogitChangeBothModified       = { fg = c.yellow,  bold = true },
    NeogitChangeNewFile            = { fg = c.green,   bold = true },

    -- Section labels
    NeogitUntrackedfiles           = { fg = c.mauve,   bold = true },
    NeogitUnstagedchanges          = { fg = c.mauve,   bold = true },
    NeogitUnmergedchanges          = { fg = c.mauve,   bold = true },
    NeogitUnpulledchanges          = { fg = c.mauve,   bold = true },
    NeogitRecentcommits            = { fg = c.mauve,   bold = true },
    NeogitStagedchanges            = { fg = c.mauve,   bold = true },
    NeogitStashes                  = { fg = c.mauve,   bold = true },
    NeogitRebasing                 = { fg = c.mauve,   bold = true },

    -- Misc
    NeogitBranch                   = { fg = c.peach,   bold = true },
    NeogitRemote                   = { fg = c.green,   bold = true },
    NeogitTagName                  = { fg = c.yellow },
    NeogitTagDistance              = { fg = c.blue },
    NeogitFilePath                 = { fg = c.blue,    italic = true },
    NeogitObjectId                 = { link = "Comment" },
    NeogitStash                    = { link = "Comment" },
    NeogitSubtleText               = { link = "Comment" },
    NeogitRebaseDone               = { link = "Comment" },
    NeogitUnmergedInto             = { link = "Function" },
    NeogitUnpulledFrom             = { link = "Function" },
    NeogitUnpushedTo               = { fg = c.lavender, bold = true },

    -- Popups
    NeogitPopupBold                = { bold = true },
    NeogitPopupSwitchKey           = { fg = c.lavender },
    NeogitPopupOptionKey           = { fg = c.lavender },
    NeogitPopupConfigKey           = { fg = c.lavender },
    NeogitPopupActionKey           = { fg = c.lavender },

    -- Notifications
    NeogitNotificationInfo         = { fg = c.blue },
    NeogitNotificationWarning      = { fg = c.yellow },
    NeogitNotificationError        = { fg = c.red },

    -- Commit graph
    NeogitGraphAuthor              = { fg = c.peach },
    NeogitGraphRed                 = { fg = c.red },
    NeogitGraphWhite               = { fg = c.text },
    NeogitGraphYellow              = { fg = c.yellow },
    NeogitGraphGreen               = { fg = c.green },
    NeogitGraphCyan                = { fg = c.teal },
    NeogitGraphBlue                = { fg = c.blue },
    NeogitGraphPurple              = { fg = c.lavender },
    NeogitGraphGray                = { fg = c.subtext1 },
    NeogitGraphOrange              = { fg = c.peach },
    NeogitGraphBoldRed             = { fg = c.red,      bold = true },
    NeogitGraphBoldWhite           = { fg = c.text,     bold = true },
    NeogitGraphBoldYellow          = { fg = c.yellow,   bold = true },
    NeogitGraphBoldGreen           = { fg = c.green,    bold = true },
    NeogitGraphBoldCyan            = { fg = c.teal,     bold = true },
    NeogitGraphBoldBlue            = { fg = c.blue,     bold = true },
    NeogitGraphBoldPurple          = { fg = c.lavender, bold = true },
    NeogitGraphBoldGray            = { fg = c.subtext1, bold = true },
    NeogitGraphBoldOrange          = { fg = c.peach,    bold = true },
  }
end

-- Catppuccin setup helper
local function setup_catppuccin(palette, is_transparent)
  local color_overrides = {}
  -- Flavour is only meaningful as a fallback when we have no palette.
  -- When palette is set, color_overrides.all replaces every slot.
  local flavor
  if palette then
    color_overrides.all = palette
    -- Pick flavour so integrations that care about dark/light work
    if palette.base then
      flavor = palette_builder.detect_dark_light(palette.base) == "dark" and "mocha" or "latte"
    else
      flavor = vim.o.background == "dark" and "mocha" or "latte"
    end
  else
    flavor = vim.o.background == "dark" and "mocha" or "latte"
  end

  require("catppuccin").setup({
    flavour = flavor,
    show_end_of_buffer = false,
    transparent_background = is_transparent,
    styles = SYNTAX_STYLES,
    color_overrides = color_overrides,
    custom_highlights = function(colors)
      return vim.tbl_extend("force", {
        -- Cursor line number (always visible)
        CursorLineNr = { fg = colors.lavender, bold = true },

        -- Visual selection - lighter, more white/neutral (overlay2 = #9f9f9e)
        Visual = { bg = colors.overlay2, style = { "bold" } },
        VisualNOS = { bg = colors.overlay2, style = { "bold" } },

        -- Cursor line background - lighter/whiter (overlay1 = #848483)
        CursorLine = { bg = colors.overlay1 },
      }, neogit_highlights(colors))
    end,
    integrations = {
      cmp = true,
      dap = true,
      dap_ui = true,
      fzf = true,
      gitsigns = true,
      grug_far = true,
      hop = true,
      neogit = true,
      notify = true,
      nvimtree = true,
      markview = true,
      semantic_tokens = true,
      treesitter = true,
      treesitter_context = true,
      which_key = true,
      snacks = { enabled = true },
      telescope = { enabled = true, style = "nvchad" },
      dropbar = { enabled = true, color_mode = true },
      indent_blankline = { enabled = true, scope_color = "lavender", colored_indent_levels = true },
      native_lsp = { enabled = true, virtual_text = { errors = { "italic" }, hints = { "italic" } } },
    },
  })
end

-- Highlight application
local function apply_highlights()
  if transparent then
    for _, group in ipairs(TRANSPARENT_GROUPS) do
      vim.api.nvim_set_hl(0, group, { bg = "none" })
    end
  end

  for group, attrs in pairs(HIGHLIGHT_OVERRIDES) do
    vim.api.nvim_set_hl(0, group, attrs)
  end
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      -- Sync: apply immediately so the editor is never unstyled
      setup_catppuccin(initial_palette, transparent)
      vim.cmd.colorscheme("catppuccin")
      apply_highlights()

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "catppuccin*",
        callback = apply_highlights,
      })

      -- Async: query terminal for real ANSI colours, then refine the palette
      terminal.query_colors(function(term_colors, bg)
        if vim.tbl_isempty(term_colors) and not bg then
          return
        end

        local full_palette = palette_builder.build(term_colors, ls_palette, bg)
        setup_catppuccin(full_palette, transparent)
        vim.cmd.colorscheme("catppuccin")
      end)
    end,
  },
}
