-- Palette builder — derives a complete Catppuccin palette from terminal
-- colours and LS_COLORS via delta interpolation between anchor points.
local M = {}

-- Default xterm ANSI hex values (baseline when OSC queries fail)
local DEFAULT_ANSI = {
  [0]  = "#000000", [1]  = "#cc0000", [2]  = "#4e9a06", [3]  = "#c4a000",
  [4]  = "#3465a4", [5]  = "#75507b", [6]  = "#06989a", [7]  = "#d3d7cf",
  [8]  = "#555753", [9]  = "#ef2929", [10] = "#8ae234", [11] = "#fce94f",
  [12] = "#729fcf", [13] = "#ad7fa8", [14] = "#34e2e2", [15] = "#eeeeec",
}

-- Grayscale ANSI indices → Catppuccin slots (swapped for light mode)
local GRAYSCALE_DARK  = { [0] = "crust", [7] = "subtext1", [8] = "surface2", [15] = "text" }
local GRAYSCALE_LIGHT = { [0] = "text",  [7] = "surface2", [8] = "subtext1", [15] = "crust" }

-- Accent ANSI indices → Catppuccin slots (same in both modes)
local ACCENTS = {
  [1]  = "red",   [2]  = "green", [3]  = "yellow",
  [4]  = "blue",  [5]  = "mauve", [6]  = "teal",
  [9]  = "maroon", [11] = "peach", [12] = "sapphire",
  [13] = "pink",  [14] = "sky",
}

-- Position of each ramp colour between crust (0.0) and text (1.0).
-- Ratios derived from Catppuccin Mocha's grayscale progression.
local RAMP = {
  crust    = 0.000,
  mantle   = 0.042,
  base     = 0.079,
  surface0 = 0.180,
  surface1 = 0.284,
  surface2 = 0.385,
  overlay0 = 0.489,
  overlay1 = 0.590,
  overlay2 = 0.694,
  subtext0 = 0.795,
  subtext1 = 0.899,
  text     = 1.000,
}

--- Convert "#rrggbb" → r, g, b (0-255)
local function hex_to_rgb(hex)
  hex = hex:gsub("^#", "")
  return tonumber(hex:sub(1, 2), 16),
    tonumber(hex:sub(3, 4), 16),
    tonumber(hex:sub(5, 6), 16)
end

--- Linearly interpolate between two hex colours.
--- @param c1 string "#rrggbb"
--- @param c2 string "#rrggbb"
--- @param t  number  0.0 = c1, 1.0 = c2
--- @return string "#rrggbb"
function M.interpolate(c1, c2, t)
  local r1, g1, b1 = hex_to_rgb(c1)
  local r2, g2, b2 = hex_to_rgb(c2)
  local r = math.floor(r1 + (r2 - r1) * t + 0.5)
  local g = math.floor(g1 + (g2 - g1) * t + 0.5)
  local b = math.floor(b1 + (b2 - b1) * t + 0.5)
  return string.format("#%02x%02x%02x", r, g, b)
end

--- Decide if a background colour is dark or light (ITU-R BT.709 luminance).
--- @param bg string "#rrggbb"
--- @return "dark"|"light"
function M.detect_dark_light(bg)
  local r, g, b = hex_to_rgb(bg)
  local lum = 0.2126 * r / 255 + 0.7152 * g / 255 + 0.0722 * b / 255
  return lum < 0.5 and "dark" or "light"
end

--- Build a complete 26-colour Catppuccin palette.
---
--- When any colour data is available (LS_COLORS, OSC 4/11) the full
--- palette is derived via delta interpolation — no base flavour needed.
--- Returns nil only when there is zero data, so the caller can fall
--- back to a stock Catppuccin flavour.
---
--- @param terminal_colors table<number, string>  ANSI index → "#rrggbb" (from OSC 4)
--- @param ls_palette      table<string, string>  Catppuccin slot → "#rrggbb" (from LS_COLORS)
--- @param bg              string|nil             terminal background from OSC 11
--- @return table<string, string>|nil  slot → "#rrggbb", or nil when no data
function M.build(terminal_colors, ls_palette, bg)
  local has_terminal = terminal_colors and not vim.tbl_isempty(terminal_colors)
  local has_ls = ls_palette and not vim.tbl_isempty(ls_palette)

  if not has_terminal and not has_ls and not bg then
    return nil
  end

  -- Detect dark / light
  local is_dark
  if bg then
    is_dark = M.detect_dark_light(bg) == "dark"
  else
    is_dark = vim.o.background ~= "light"
  end

  local p = {}

  -- 1. Map grayscale ANSI → slots (endpoints swap for light mode)
  local gray_map = is_dark and GRAYSCALE_DARK or GRAYSCALE_LIGHT
  for idx, slot in pairs(gray_map) do
    p[slot] = terminal_colors[idx] or DEFAULT_ANSI[idx]
  end

  -- 2. Map accent ANSI → slots
  for idx, slot in pairs(ACCENTS) do
    p[slot] = terminal_colors[idx] or DEFAULT_ANSI[idx]
  end

  -- 3. LS_COLORS overrides (exact colours beat ANSI defaults)
  for slot, hex in pairs(ls_palette or {}) do
    p[slot] = hex
  end

  -- 4. Terminal background
  if bg then
    p.base = bg
  end

  -- 5. Fill every missing ramp slot by interpolating between crust ↔ text
  local crust = p.crust
  local text  = p.text
  if crust and text then
    for slot, pos in pairs(RAMP) do
      if not p[slot] then
        p[slot] = M.interpolate(crust, text, pos)
      end
    end
  end

  -- 6. Derive missing accent colours
  if p.maroon and p.text then
    p.rosewater = p.rosewater or M.interpolate(p.maroon, p.text, 0.6)
  end
  if p.red and p.rosewater then
    p.flamingo = p.flamingo or M.interpolate(p.red, p.rosewater, 0.5)
  end
  if p.blue and p.text then
    p.lavender = p.lavender or M.interpolate(p.blue, p.text, 0.4)
  end

  return p
end

return M
