local git = require("sysinit.utils.diff_review.git")

local M = {}

local state = {
  default_provider = "opencode",
  branch_fallback = "HEAD~1",
  prompts = {
    review = "Review this diff carefully. "
      .. "Identify any bugs, logic errors, security issues, missing edge-cases, "
      .. "or places where the intent of the change is unclear. "
      .. "Be concise and specific - cite line numbers where relevant.",
    hunk = "Review this specific hunk. "
      .. "What does it change, is the change correct, and are there any issues?",
  },
  providers = {},
}

local function notify(message, level)
  vim.notify("[diff-review] " .. message, level or vim.log.levels.INFO)
end

local function build_message(prompt, lines)
  local diff_text = table.concat(lines, "\n")
  return string.format("%s\n\n```diff\n%s\n```", prompt, diff_text)
end

local function resolve_prompt(scope, prompt)
  if prompt and prompt ~= "" then
    return prompt
  end
  if scope == "hunk" then
    return state.prompts.hunk
  end
  return state.prompts.review
end

---@param name string
---@param provider table|function
function M.register_provider(name, provider)
  if type(name) ~= "string" or name == "" then
    error("Provider name must be a non-empty string")
  end

  if type(provider) == "function" then
    provider = {
      send = provider,
      available = function()
        return true
      end,
    }
  end

  if type(provider) ~= "table" or type(provider.send) ~= "function" then
    error(string.format("Provider '%s' must define send(payload)", name))
  end

  if type(provider.available) ~= "function" then
    provider.available = function()
      return true
    end
  end

  state.providers[name] = provider
end

---@return string[]
function M.available_providers()
  local names = vim.tbl_keys(state.providers)
  table.sort(names)
  return names
end

function M.setup(opts)
  opts = opts or {}

  if opts.default_provider and opts.default_provider ~= "" then
    state.default_provider = opts.default_provider
  end

  if opts.branch_fallback ~= nil then
    state.branch_fallback = opts.branch_fallback
  end

  if opts.prompts then
    state.prompts = vim.tbl_deep_extend("force", state.prompts, opts.prompts)
  end

  if opts.providers then
    for name, provider in pairs(opts.providers) do
      M.register_provider(name, provider)
    end
  end
end

local function current_hunk_lines()
  local ok, gs = pcall(require, "gitsigns")
  if not ok then
    return nil, "gitsigns.nvim is not available"
  end

  local hunks = gs.get_hunks and gs.get_hunks()
  if not hunks or #hunks == 0 then
    return nil, "No hunks in buffer"
  end

  local cursor_line = vim.fn.line(".")
  local selected

  for _, hunk in ipairs(hunks) do
    local start_line = hunk.added.start
    local end_line = start_line + math.max(hunk.added.count - 1, 0)
    if cursor_line >= start_line and cursor_line <= end_line then
      selected = hunk
      break
    end
  end

  selected = selected or hunks[1]
  return vim.list_extend({ selected.head }, selected.lines), nil
end

local function resolve_provider(name)
  local provider_name = name or state.default_provider
  local provider = state.providers[provider_name]
  if not provider then
    return nil, string.format("Provider '%s' is not registered", provider_name)
  end
  if not provider.available() then
    return nil, string.format("Provider '%s' is not available", provider_name)
  end
  return provider, nil
end

---@param lines string[]|nil
---@param prompt string
---@param opts? { provider?: string, submit?: boolean, meta?: table, notify_on_empty?: boolean, scope?: string, cwd?: string }
---@return boolean, string|nil
function M.send(lines, prompt, opts)
  opts = opts or {}

  if not lines or #lines == 0 then
    if opts.notify_on_empty ~= false then
      notify("No diff output - nothing to review", vim.log.levels.WARN)
    end
    return false, "No diff output"
  end

  local provider, provider_err = resolve_provider(opts.provider)
  if not provider then
    notify(provider_err, vim.log.levels.ERROR)
    return false, provider_err
  end

  local submit = opts.submit
  if submit == nil then
    submit = true
  end

  local payload = {
    message = build_message(prompt, lines),
    prompt = prompt,
    lines = lines,
    submit = submit,
    scope = opts.scope,
    meta = opts.meta or {},
    cwd = opts.cwd,
  }

  local ok, err = pcall(provider.send, payload)
  if not ok then
    notify(string.format("Provider '%s' failed: %s", opts.provider or state.default_provider, err), vim.log.levels.ERROR)
    return false, err
  end

  return true, nil
end

---@param scope "head"|"staged"|"branch"|"file"|"hunk"
---@param opts? { provider?: string, submit?: boolean, prompt?: string, cwd?: string, file?: string, merge_base_targets?: string[], branch_fallback?: string, notify_on_empty?: boolean }
---@return boolean, string|nil
function M.review(scope, opts)
  opts = opts or {}

  local lines, err
  if scope == "hunk" then
    lines, err = current_hunk_lines()
  else
    lines, err = git.diff_lines(scope, {
      cwd = opts.cwd,
      file = opts.file,
      merge_base_targets = opts.merge_base_targets,
      branch_fallback = opts.branch_fallback or state.branch_fallback,
    })
  end

  if err then
    notify(err, vim.log.levels.WARN)
    return false, err
  end

  return M.send(lines, resolve_prompt(scope, opts.prompt), {
    provider = opts.provider,
    submit = opts.submit,
    notify_on_empty = opts.notify_on_empty,
    scope = scope,
    cwd = opts.cwd,
    meta = {
      file = opts.file,
    },
  })
end

function M.review_head(opts)
  return M.review("head", opts)
end

function M.review_staged(opts)
  return M.review("staged", opts)
end

function M.review_branch(opts)
  return M.review("branch", opts)
end

function M.review_file(opts)
  opts = opts or {}
  opts.file = opts.file or vim.fn.expand("%:p")
  if not opts.file or opts.file == "" then
    notify("No file in current buffer", vim.log.levels.WARN)
    return false, "No file in current buffer"
  end
  return M.review("file", opts)
end

function M.review_hunk(opts)
  return M.review("hunk", opts)
end

---@param scope "head"|"staged"|"branch"
---@param opts? { cwd?: string, merge_base_targets?: string[], branch_fallback?: string }
---@return boolean, string|nil
function M.open_picker(scope, opts)
  opts = opts or {}
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    local err = "snacks.nvim is not available"
    notify(err, vim.log.levels.ERROR)
    return false, err
  end

  if scope == "head" then
    snacks.picker.git_diff()
    return true, nil
  end

  if scope == "staged" then
    snacks.picker.git_diff({ staged = true })
    return true, nil
  end

  if scope == "branch" then
    local base, err = git.merge_base({
      cwd = opts.cwd,
      merge_base_targets = opts.merge_base_targets,
    })
    if not base or base == "" then
      base = opts.branch_fallback or state.branch_fallback
      if not base or base == "" then
        notify(err or "Could not determine merge-base", vim.log.levels.WARN)
        return false, err or "Could not determine merge-base"
      end
    end
    snacks.picker.git_diff({ base = base })
    return true, nil
  end

  local err = string.format("Unsupported picker scope: %s", scope)
  notify(err, vim.log.levels.ERROR)
  return false, err
end

function M.picker_head(opts)
  return M.open_picker("head", opts)
end

function M.picker_staged(opts)
  return M.open_picker("staged", opts)
end

function M.picker_branch(opts)
  return M.open_picker("branch", opts)
end

M.register_provider("opencode", {
  available = function()
    return pcall(require, "opencode")
  end,
  send = function(payload)
    local opencode = require("opencode")
    opencode.prompt(payload.message, { submit = payload.submit })
  end,
})

return M
