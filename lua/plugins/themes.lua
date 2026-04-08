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

-- Comprehensive neogit highlight overrides, based on the authoritative group list
-- in neogit's built-in :help docs. Catppuccin's integration is incomplete (missing
-- ~40 groups) and uses surface0 for diff context, which maps near-black with
-- terminal-derived palettes causing "black bar" artifacts.
local function neogit_highlights(c)
  local U = require("catppuccin.utils.colors")

  -- Shared section-header style — all status-buffer section labels link here
  local section = { fg = c.mauve, bold = true }

  return {
    -- ── Window / float surfaces ──────────────────────────────────────────────
    -- Both NeogitFloat AND NeogitNormalFloat must exist: neogit's hl.lua
    -- defines NeogitNormalFloat = { link = "NeogitNormal" } with default=true,
    -- and then NeogitFloatBorder = { link = "NeogitNormalFloat" }.
    -- We take ownership of both so neither falls through to a dark background.
    NeogitNormal             = { link = "Normal" },
    NeogitFloat              = { link = "NormalFloat" },
    NeogitNormalFloat        = { link = "NormalFloat" },
    NeogitFloatBorder        = { link = "FloatBorder" },
    NeogitFloatHeader        = { fg = c.blue,      bg = U.darken(c.blue, 0.12, c.base), bold = true },
    NeogitFloatHeaderHighlight = { fg = c.sapphire, bg = U.darken(c.blue, 0.20, c.base), bold = true },
    NeogitWinSeparator       = { link = "WinSeparator" },
    NeogitSignColumn         = { fg = "NONE", bg = "NONE" },
    NeogitFoldColumn         = { fg = "NONE", bg = "NONE" },
    NeogitCursorLine         = { link = "CursorLine" },
    NeogitCursorLineNr       = { link = "CursorLineNr" },

    -- ── Commit view description ───────────────────────────────────────────────
    -- Applied as a col-level container highlight on the commit message body.
    -- MUST be explicitly defined — undefined = stacked bg inheritance = black block.
    NeogitCommitViewDescription = { link = "Normal" },

    -- ── Diff stats overview ("+5 -3" inline in file list) ────────────────────
    NeogitDiffAdditions      = { fg = c.green },
    NeogitDiffDeletions      = { fg = c.red },

    -- ── Diff context ─────────────────────────────────────────────────────────
    -- MUST use `link` (not `bg = "NONE"`) because neogit's hl.lua calls
    -- is_set() which does nvim_get_hl and checks tbl_isempty. An empty-attr
    -- group (bg="NONE", no fg) returns an empty table → is_set=false →
    -- neogit overwrites with palette.bg1 (#26292e) via default=true.
    -- link="Normal" guarantees is_set=true and adapts to float vs normal windows.
    -- ContextHighlight covers ALL lines in the focused hunk, so it must be
    -- very subtle — CursorLine is perfect: catppuccin already tunes it well.
    NeogitDiffContext          = { link = "Normal" },
    NeogitDiffContextHighlight = { link = "CursorLine" },
    NeogitDiffContextCursor    = { link = "CursorLine" },

    -- ── Diff additions ───────────────────────────────────────────────────────
    -- Link to Neovim's DiffAdd/DiffDelete so the colours scale with the
    -- terminal palette automatically (catppuccin already styles these).
    -- Inline variants get an explicit, slightly more saturated bg.
    NeogitDiffAdd            = { link = "DiffAdd" },
    NeogitDiffAddHighlight   = { link = "DiffAdd" },
    NeogitDiffAddCursor      = { link = "DiffAdd" },
    NeogitDiffAddInline      = { bg = c.surface1, fg = c.green, bold = true },

    -- ── Diff deletions ───────────────────────────────────────────────────────
    NeogitDiffDelete         = { link = "DiffDelete" },
    NeogitDiffDeleteHighlight = { link = "DiffDelete" },
    NeogitDiffDeleteCursor   = { link = "DiffDelete" },
    NeogitDiffDeleteInline   = { bg = c.surface1, fg = c.red,   bold = true },

    -- ── Diff file header ─────────────────────────────────────────────────────
    -- No bg attr → would be empty → neogit default wins. Use link="Normal" as base.
    NeogitDiffHeader          = { fg = c.blue, bold = true },
    NeogitDiffHeaderHighlight = { fg = c.blue, bg = c.surface0, bold = true },
    NeogitDiffHeaderCursor    = { fg = c.blue, bg = c.surface1, bold = true },

    -- ── Hunk header ──────────────────────────────────────────────────────────
    NeogitHunkHeader          = { fg = c.blue,  bg = c.surface0, bold = true },
    NeogitHunkHeaderHighlight = { fg = c.blue,  bg = c.surface1, bold = true },
    NeogitHunkHeaderCursor    = { fg = c.sapphire, bg = c.surface1, bold = true },

    -- ── Merge hunk header ────────────────────────────────────────────────────
    NeogitHunkMergeHeader          = { fg = c.teal, bg = c.surface0, bold = true },
    NeogitHunkMergeHeaderHighlight = { fg = c.teal, bg = c.surface1, bold = true },
    NeogitHunkMergeHeaderCursor    = { fg = c.teal, bg = c.surface1, bold = true },

    -- ── Commit view header ───────────────────────────────────────────────────
    NeogitCommitViewHeader          = { fg = c.blue,    bg = c.surface0, bold = true },
    NeogitCommitViewHeaderHighlight = { fg = c.sapphire, bg = c.surface1, bold = true },
    NeogitCommitViewHeaderCursor    = { fg = c.sapphire, bg = c.surface1, bold = true },

    -- ── Section headers ──────────────────────────────────────────────────────
    NeogitSectionHeader      = section,
    NeogitSectionHeaderCount = { fg = c.subtext1, bold = true },
    -- All status-buffer section labels link to the shared style
    NeogitUntrackedfiles     = section,
    NeogitUnstagedchanges    = section,
    NeogitUnmergedchanges    = section,
    NeogitUnpulledchanges    = section,
    NeogitUnpushedchanges    = section,  -- the section variant (different from NeogitUnpushedTo)
    NeogitStagedchanges      = section,
    NeogitRecentcommits      = section,
    NeogitStashes            = section,
    NeogitRebasing           = section,
    NeogitReverting          = section,
    NeogitPicking            = section,
    NeogitMerging            = section,
    NeogitBisecting          = section,
    -- These link to Function in neogit's own hl.lua (keep parity)
    NeogitUnmergedInto       = { link = "Function" },
    NeogitUnpulledFrom       = { link = "Function" },
    NeogitUnpushedTo         = { fg = c.lavender, bold = true },

    -- ── Status HEAD / active item ────────────────────────────────────────────
    NeogitStatusHEAD         = { fg = c.text,    bold = true },
    NeogitActiveItem         = { fg = c.peach,   bold = true },
    NeogitBranchHead         = { fg = c.sapphire, bold = true },

    -- ── Fold ─────────────────────────────────────────────────────────────────
    NeogitFold               = { fg = "NONE", bg = "NONE" },  -- never create a black bar

    -- ── Branch / remote / tag ────────────────────────────────────────────────
    NeogitBranch             = { fg = c.peach,   bold = true },
    NeogitRemote             = { fg = c.green,   bold = true },
    NeogitTagName            = { fg = c.yellow },
    NeogitTagDistance        = { fg = c.blue },

    -- ── Misc labels ──────────────────────────────────────────────────────────
    NeogitFilePath           = { fg = c.blue,    italic = true },
    NeogitObjectId           = { link = "Comment" },
    NeogitStash              = { link = "Comment" },
    NeogitSubtleText         = { link = "Comment" },
    NeogitRebaseDone         = { link = "Comment" },

    -- ── Change-type labels ───────────────────────────────────────────────────
    NeogitChangeModified     = { fg = c.blue,    bold = true },
    NeogitChangeAdded        = { fg = c.green,   bold = true },
    NeogitChangeDeleted      = { fg = c.red,     bold = true },
    NeogitChangeRenamed      = { fg = c.mauve,   bold = true },
    NeogitChangeUpdated      = { fg = c.peach,   bold = true },
    NeogitChangeCopied       = { fg = c.pink,    bold = true },
    NeogitChangeNewFile      = { fg = c.green,   bold = true },
    NeogitChangeUnmerged     = { fg = c.yellow,  bold = true },

    -- ── Commit graph ─────────────────────────────────────────────────────────
    NeogitGraphAuthor        = { fg = c.peach },
    NeogitGraphBlack         = { fg = c.surface2 },
    NeogitGraphBoldBlack     = { fg = c.surface2,  bold = true },
    NeogitGraphRed           = { fg = c.red },
    NeogitGraphBoldRed       = { fg = c.red,       bold = true },
    NeogitGraphGreen         = { fg = c.green },
    NeogitGraphBoldGreen     = { fg = c.green,     bold = true },
    NeogitGraphYellow        = { fg = c.yellow },
    NeogitGraphBoldYellow    = { fg = c.yellow,    bold = true },
    NeogitGraphBlue          = { fg = c.blue },
    NeogitGraphBoldBlue      = { fg = c.blue,      bold = true },
    NeogitGraphPurple        = { fg = c.lavender },
    NeogitGraphBoldPurple    = { fg = c.lavender,  bold = true },
    NeogitGraphCyan          = { fg = c.teal },
    NeogitGraphBoldCyan      = { fg = c.teal,      bold = true },
    NeogitGraphWhite         = { fg = c.text },
    NeogitGraphBoldWhite     = { fg = c.text,      bold = true },
    NeogitGraphGray          = { fg = c.subtext1 },
    NeogitGraphBoldGray      = { fg = c.subtext1,  bold = true },
    NeogitGraphOrange        = { fg = c.peach },
    NeogitGraphBoldOrange    = { fg = c.peach,     bold = true },

    -- ── GPG signatures ───────────────────────────────────────────────────────
    NeogitSignatureGood           = { fg = c.green },
    NeogitSignatureGoodUnknown    = { fg = c.teal },
    NeogitSignatureGoodExpired    = { fg = c.yellow },
    NeogitSignatureGoodExpiredKey = { fg = c.yellow },
    NeogitSignatureGoodRevokedKey = { fg = c.peach },
    NeogitSignatureBad            = { fg = c.red,     bold = true },
    NeogitSignatureMissing        = { fg = c.subtext1 },
    NeogitSignatureNone           = { fg = c.subtext0 },

    -- ── Popup keys & states ──────────────────────────────────────────────────
    NeogitPopupSectionTitle  = { fg = c.mauve,    bold = true },
    NeogitPopupBranchName    = { fg = c.peach,    bold = true },
    NeogitPopupBold          = { bold = true },
    NeogitPopupSwitchKey     = { fg = c.lavender },
    NeogitPopupSwitchEnabled = { fg = c.green },
    NeogitPopupSwitchDisabled = { fg = c.subtext0 },
    NeogitPopupOptionKey     = { fg = c.lavender },
    NeogitPopupOptionEnabled = { fg = c.green },
    NeogitPopupOptionDisabled = { fg = c.subtext0 },
    NeogitPopupConfigKey     = { fg = c.lavender },
    NeogitPopupConfigEnabled = { fg = c.green },
    NeogitPopupConfigDisabled = { fg = c.subtext0 },
    NeogitPopupActionKey     = { fg = c.lavender },
    NeogitPopupActionDisabled = { fg = c.subtext0 },

    -- ── Command history console ───────────────────────────────────────────────
    NeogitCommandText        = { fg = c.text },
    NeogitCommandTime        = { fg = c.subtext1,  italic = true },
    NeogitCommandCodeNormal  = { fg = c.green },
    NeogitCommandCodeError   = { fg = c.red,       bold = true },

    -- ── Notifications (internal snacks/nvim-notify bridge) ───────────────────
    NeogitNotificationInfo   = { fg = c.blue },
    NeogitNotificationWarning = { fg = c.yellow },
    NeogitNotificationError  = { fg = c.red },
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
