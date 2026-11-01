-- The shared ty command is the pane-control boundary for tmux workflows.
local M = {}

---@param args string[]
---@param stdin? string
---@return string|nil stdout, string|nil err
function M.cli(args, stdin)
  local cmd = { "ty" }
  vim.list_extend(cmd, args)
  local ok, process = pcall(vim.system, cmd, { text = true, stdin = stdin })
  if not ok then
    return nil, tostring(process)
  end
  local result = process:wait(2000)
  if result.code ~= 0 then
    return nil, result.code == 124 and "ty timed out" or vim.trim(result.stderr or "ty failed")
  end
  return vim.trim(result.stdout or ""), nil
end

---@param pane_id string
---@return boolean
function M.pane_alive(pane_id)
  local out = M.cli({ "panes" })
  if not out then
    return false
  end
  local ok, result = pcall(vim.json.decode, out)
  if not ok or type(result) ~= "table" or type(result.panes) ~= "table" then
    return false
  end
  for _, pane in ipairs(result.panes) do
    if pane.pane_id == pane_id then
      return true
    end
  end
  return false
end

---@param opts { parent: string, cwd?: string, percent?: integer, side?: "left"|"right", argv: string[] }
---@return string|nil pane_id, string|nil err
function M.split(opts)
  if type(opts.parent) ~= "string" or opts.parent == "" then
    return nil, "tmux parent pane is unavailable"
  end
  local args = { "pane", "spawn", opts.parent, "--direction", opts.side == "left" and "left" or "right" }
  if opts.cwd then
    vim.list_extend(args, { "--cwd", opts.cwd })
  end
  if opts.percent then
    vim.list_extend(args, { "--percent", tostring(opts.percent) })
  end
  vim.list_extend(args, { "--" })
  vim.list_extend(args, opts.argv)
  local out, err = M.cli(args)
  if not out then
    return nil, err
  end
  local ok, result = pcall(vim.json.decode, out)
  if not ok or type(result) ~= "table" or type(result.pane_id) ~= "string" then
    return nil, "ty returned an invalid pane result"
  end
  return result.pane_id, nil
end

---@param pane_id string
---@param text string
---@param opts? { submit?: boolean }
---@return boolean
function M.send_text(pane_id, text, opts)
  opts = opts or {}
  local args = { "pane", "send" }
  if opts.submit then
    table.insert(args, "--submit")
  end
  table.insert(args, pane_id)
  return M.cli(args, text) ~= nil
end

---@param pane_id string
function M.activate(pane_id)
  M.cli({ "pane", "focus", pane_id })
end

---@param pane_id string
function M.kill(pane_id)
  M.cli({ "pane", "close", pane_id })
end

return M
