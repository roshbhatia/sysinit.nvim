local lifecycle = require("harness.lifecycle")

local lc

local function ensure_lifecycle()
  if not lc then
    lc = lifecycle.build("pi", { name = "pi", percent = 0.4 })
  end
  return lc
end

return {
  name = "pi",
  label = "Pi",
  available = function()
    return vim.fn.executable("pi") == 1
  end,
  toggle = function()
    ensure_lifecycle().toggle()
  end,
  focus = function()
    ensure_lifecycle().focus()
  end,
  is_visible = function()
    if not lc then
      return false
    end
    return lc.is_visible()
  end,
  send = function(text, _opts)
    local ok, pi = pcall(require, "pi")
    if not ok then
      vim.notify("pi: plugin not loadable", vim.log.levels.WARN)
      return
    end
    pi.run({
      message = text,
      bufnr = vim.api.nvim_get_current_buf(),
    })
  end,
  kill = function()
    if lc then
      lc.kill()
    end
  end,
}
