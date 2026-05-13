local function opencode_ok()
  return pcall(require, "opencode")
end

return {
  name = "opencode",
  label = "OpenCode",
  available = function()
    return opencode_ok() and vim.fn.executable("opencode") == 1
  end,
  toggle = function()
    require("opencode").toggle()
  end,
  focus = function()
    require("opencode").toggle()
  end,
  is_visible = function()
    return false
  end,
  send = function(text, opts)
    opts = opts or {}
    require("opencode").prompt(text, { submit = opts.submit ~= false })
    -- Focus the opencode pane so the user can review/edit before submitting.
    -- opencode.toggle() shows the pane if hidden, but also hides if visible;
    -- if it was already visible this is benign because the user just
    -- triggered a prompt and would naturally look at it.
    pcall(function()
      require("opencode").toggle()
    end)
  end,
  kill = function()
    pcall(function()
      require("opencode").toggle()
    end)
  end,
}
