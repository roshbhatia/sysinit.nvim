local function find_claude_terminal()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      local marker = vim.b[buf].snacks_terminal
      if marker and type(marker) == "table" then
        local cmd = marker.cmd
        if type(cmd) == "string" and cmd:find("claude", 1, true) then
          return buf
        end
        if type(cmd) == "table" and cmd[1] and tostring(cmd[1]):find("claude", 1, true) then
          return buf
        end
      end
      local name = vim.api.nvim_buf_get_name(buf)
      if name:find("claude", 1, true) then
        return buf
      end
    end
  end
  return nil
end

local function find_claude_window(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end
  return nil
end

local function chansend_to_buf(buf, text, submit)
  local chan = vim.b[buf].terminal_job_id
  if not chan then
    return false
  end
  local payload = submit and (text .. "\r") or text
  local ok = pcall(vim.api.nvim_chan_send, chan, payload)
  if ok then
    pcall(function()
      local win = find_claude_window(buf)
      if win then
        vim.api.nvim_set_current_win(win)
        vim.cmd("startinsert")
      end
    end)
  end
  return ok
end

local function wezterm_send(pane_id, text, submit)
  local payload = submit and (text .. "\r") or text
  local tmp = vim.fn.tempname()
  local ok = pcall(vim.fn.writefile, vim.split(payload, "\n", { plain = true }), tmp, "b")
  if not ok then
    return false
  end
  vim.fn.system(string.format(
    "wezterm cli send-text --no-paste --pane-id %d < %s",
    pane_id,
    vim.fn.shellescape(tmp)
  ))
  local shell_ok = vim.v.shell_error == 0
  pcall(vim.fn.delete, tmp)
  -- Focus the pane so the user can add more context before submitting.
  vim.fn.jobstart(
    { "wezterm", "cli", "activate-pane", "--pane-id", tostring(pane_id) },
    { detach = true }
  )
  return shell_ok
end

local function wezterm_pane_alive(pane_id)
  local res = vim.fn.system({ "wezterm", "cli", "list", "--format", "json" })
  if vim.v.shell_error ~= 0 then
    return false
  end
  local ok, panes = pcall(vim.json.decode, res)
  if not ok or type(panes) ~= "table" then
    return false
  end
  for _, p in ipairs(panes) do
    if p.pane_id == pane_id then
      return true
    end
  end
  return false
end

local function clipboard_fallback(text)
  pcall(vim.fn.setreg, "+", text)
  pcall(vim.fn.setreg, "*", text)
  vim.notify(
    "claudecode: send failed — prompt copied to clipboard, paste into the Claude pane",
    vim.log.levels.WARN
  )
end

local function try_send(text, submit)
  -- 1. wezterm pane (out-of-process)
  local pane_id = vim.g.harness_wezterm_pane_claudecode
  if pane_id and wezterm_pane_alive(pane_id) then
    if wezterm_send(pane_id, text, submit) then
      return true
    end
  end
  -- 2. snacks nvim terminal buffer
  local buf = find_claude_terminal()
  if buf and chansend_to_buf(buf, text, submit) then
    return true
  end
  return false
end

return {
  name = "claudecode",
  label = "Claude",
  options_schema = {
    { name = "dangerous", flag = "--dangerously-skip-permissions", kind = "toggle", default = true },
    { name = "continue",  flag = "-c",                              kind = "toggle" },
    { name = "resume",    flag = "-r",                              kind = "toggle" },
    { name = "model",     flag = "--model",                         kind = "value", prompt = "Model alias or full name (e.g. opus, sonnet)" },
  },
  available = function()
    return pcall(require, "claudecode") and vim.fn.executable("claude") == 1
  end,
  toggle = function()
    local args = require("harness.options").build_args("claudecode")
    if #args > 0 then
      vim.cmd("ClaudeCode " .. table.concat(args, " "))
    else
      vim.cmd("ClaudeCode")
    end
  end,
  focus = function()
    pcall(vim.cmd, "ClaudeCodeFocus")
  end,
  is_visible = function()
    local pane_id = vim.g.harness_wezterm_pane_claudecode
    if pane_id and wezterm_pane_alive(pane_id) then
      return true
    end
    local buf = find_claude_terminal()
    return buf ~= nil and find_claude_window(buf) ~= nil
  end,
  send = function(text, opts)
    opts = opts or {}
    local submit = opts.submit ~= false

    if try_send(text, submit) then
      return
    end

    -- Pane isn't up yet — ensure :ClaudeCode, retry, then clipboard.
    pcall(vim.cmd, "ClaudeCode")
    vim.defer_fn(function()
      if try_send(text, submit) then
        return
      end
      clipboard_fallback(text)
    end, 400)
  end,
  kill = function()
    local pane_id = vim.g.harness_wezterm_pane_claudecode
    if pane_id then
      vim.fn.system({ "wezterm", "cli", "kill-pane", "--pane-id", tostring(pane_id) })
      vim.g.harness_wezterm_pane_claudecode = nil
      return
    end
    local buf = find_claude_terminal()
    if buf then
      local win = find_claude_window(buf)
      if win then
        pcall(vim.api.nvim_win_close, win, true)
      end
    end
  end,
}
