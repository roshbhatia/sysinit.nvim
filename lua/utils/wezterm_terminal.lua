-- Wezterm terminal provider for plugins implementing claudecode.nvim's
-- ClaudeCode.TerminalProvider contract.
--
-- Spawns the agent CLI in a wezterm pane split (mirroring the pattern used
-- by neph.nvim) and tracks the pane_id for toggle/focus state. The pane is
-- out-of-process, so get_active_bufnr() returns nil and lifecycle is owned
-- entirely by wezterm CLI calls.

local M = {}

local function pane_alive(pane_id, callback)
  vim.fn.jobstart({ "wezterm", "cli", "list", "--format", "json" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local raw = table.concat(data or {}, "\n")
      local ok, panes = pcall(vim.json.decode, raw)
      if not ok or type(panes) ~= "table" then
        callback(false)
        return
      end
      for _, p in ipairs(panes) do
        if p.pane_id == pane_id then
          callback(true)
          return
        end
      end
      callback(false)
    end,
    on_exit = function(_, code)
      if code ~= 0 then callback(false) end
    end,
  })
end

local function activate_pane(pane_id)
  vim.fn.jobstart({ "wezterm", "cli", "activate-pane", "--pane-id", tostring(pane_id) }, { detach = true })
end

local function kill_pane(pane_id)
  vim.fn.jobstart({ "wezterm", "cli", "kill-pane", "--pane-id", tostring(pane_id) }, { detach = true })
end

local function build_env_prefix(env_table)
  local parts = {}
  for k, v in pairs(env_table or {}) do
    parts[#parts + 1] = string.format("export %s=%s;", k, vim.fn.shellescape(tostring(v)))
  end
  return table.concat(parts, " ")
end

--- Build a claudecode-compatible provider that uses wezterm panes.
--- @param opts? { name?: string, percent?: number, side?: "left"|"right" }
--- @return table provider
function M.build_provider(opts)
  opts = opts or {}
  local name = opts.name or "agent"

  local Provider = {}
  local pane_id = nil
  local parent_pane_id = tonumber(vim.env.WEZTERM_PANE)
  local cfg = {}

  local function spawn(cmd_string, env_table, effective_config, focus)
    if not parent_pane_id then
      vim.notify(
        ("%s/wezterm: WEZTERM_PANE not set; cannot split"):format(name),
        vim.log.levels.ERROR
      )
      return
    end

    local env_str = build_env_prefix(env_table)
    local full_cmd = env_str ~= "" and (env_str .. " " .. cmd_string) or cmd_string

    local merged = vim.tbl_extend("force", cfg, effective_config or {})
    local pct = math.floor((opts.percent or merged.split_width_percentage or 0.4) * 100)
    local side_flag = ((opts.side or merged.split_side) == "left") and "--left" or "--right"
    local cwd = vim.fn.getcwd()

    -- Redirect stderr; wezterm prints config-reload notices to stderr that
    -- corrupt the pane-id integer on stdout.
    local spawn_cmd = string.format(
      "wezterm cli split-pane --pane-id %d %s --percent %d --cwd %s -- sh -c %s 2>/dev/null",
      parent_pane_id,
      side_flag,
      pct,
      vim.fn.shellescape(cwd),
      vim.fn.shellescape(full_cmd)
    )

    local result = vim.fn.system(spawn_cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify(
        ("%s/wezterm: spawn failed (exit %d)"):format(name, vim.v.shell_error),
        vim.log.levels.ERROR
      )
      return
    end

    local id = tonumber(vim.trim(result))
    if not id then
      vim.notify(("%s/wezterm: could not parse pane id"):format(name), vim.log.levels.ERROR)
      return
    end
    pane_id = id

    if focus then
      vim.defer_fn(function() activate_pane(pane_id) end, 80)
    end
  end

  function Provider.setup(term_config)
    cfg = term_config or {}
  end

  function Provider.is_available()
    return parent_pane_id ~= nil and vim.fn.executable("wezterm") == 1
  end

  function Provider.open(cmd_string, env_table, effective_config, focus)
    if pane_id then
      pane_alive(pane_id, function(alive)
        if alive then
          if focus then activate_pane(pane_id) end
        else
          pane_id = nil
          spawn(cmd_string, env_table, effective_config, focus)
        end
      end)
      return
    end
    spawn(cmd_string, env_table, effective_config, focus)
  end

  function Provider.close()
    if pane_id then
      kill_pane(pane_id)
      pane_id = nil
    end
  end

  function Provider.simple_toggle(cmd_string, env_table, effective_config)
    if pane_id then
      pane_alive(pane_id, function(alive)
        if alive then
          Provider.close()
        else
          pane_id = nil
          spawn(cmd_string, env_table, effective_config, true)
        end
      end)
    else
      spawn(cmd_string, env_table, effective_config, true)
    end
  end

  function Provider.focus_toggle(cmd_string, env_table, effective_config)
    if pane_id then
      pane_alive(pane_id, function(alive)
        if alive then
          activate_pane(pane_id)
        else
          pane_id = nil
          spawn(cmd_string, env_table, effective_config, true)
        end
      end)
    else
      spawn(cmd_string, env_table, effective_config, true)
    end
  end

  Provider.toggle = Provider.simple_toggle

  function Provider.get_active_bufnr()
    return nil
  end

  -- Kill orphan pane when nvim exits (matches existing claudecode wezterm hygiene)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("wezterm_terminal_" .. name, { clear = true }),
    callback = function()
      if pane_id then kill_pane(pane_id) end
    end,
  })

  return Provider
end

return M
