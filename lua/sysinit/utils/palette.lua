-- Palette builder — merges terminal colours + LS_COLORS into Catppuccin overrides
local M = {}

local ANSI_MAP = require("sysinit.utils.terminal").ANSI_TO_CATPPUCCIN

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

--- Build a Catppuccin `color_overrides` table from terminal + LS_COLORS data.
---
--- @param terminal_colors table<number, string>  ANSI index → "#rrggbb" (from OSC 4)
--- @param ls_palette      table<string, string>  Catppuccin slot → "#rrggbb" (from LS_COLORS)
--- @param bg              string|nil             terminal background from OSC 11
--- @return table<string, string> slot → "#rrggbb"
function M.build(terminal_colors, ls_palette, bg)
  local p = {}

  -- 1. Map ANSI terminal colours to Catppuccin slots
  for idx, slot in pairs(ANSI_MAP) do
    if terminal_colors[idx] then
      p[slot] = terminal_colors[idx]
    end
  end

  -- 2. Layer LS_COLORS overrides (higher priority for exact colours)
  for slot, hex in pairs(ls_palette or {}) do
    p[slot] = hex
  end

  -- 3. Set base from terminal background
  if bg then
    p.base = bg
  end

  -- 4. Derive missing structural colours via interpolation
  local base = p.base
  local crust = p.crust
  local text = p.text
  local s2 = p.surface2
  local sub1 = p.subtext1

  if base and crust then
    p.mantle = p.mantle or M.interpolate(base, crust, 0.5)
  end

  if base and (s2 or text) then
    local far = s2 or text
    p.surface0 = p.surface0 or M.interpolate(base, far, 0.15)
    p.surface1 = p.surface1 or M.interpolate(base, far, 0.25)
  end

  if s2 and (sub1 or text) then
    local far = sub1 or text
    p.overlay0 = p.overlay0 or M.interpolate(s2, far, 0.2)
    p.overlay1 = p.overlay1 or M.interpolate(s2, far, 0.4)
    p.overlay2 = p.overlay2 or M.interpolate(s2, far, 0.6)
    p.subtext0 = p.subtext0 or M.interpolate(p.overlay2 or s2, far, 0.5)
  end

  -- 5. Derive missing accent colours
  if p.maroon and text then
    p.rosewater = p.rosewater or M.interpolate(p.maroon, text, 0.5)
  end
  if p.red and p.rosewater then
    p.flamingo = p.flamingo or M.interpolate(p.red, p.rosewater, 0.5)
  end
  if p.blue and text then
    p.lavender = p.lavender or M.interpolate(p.blue, text, 0.4)
  end

  return p
end

return M
