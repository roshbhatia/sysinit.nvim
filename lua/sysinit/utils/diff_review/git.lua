local M = {}

local DEFAULT_MERGE_BASE_TARGETS = {
  "origin/HEAD",
  "origin/main",
  "origin/master",
}

---@param cwd? string
---@return boolean
function M.in_git_repo(cwd)
  local result = vim.system({ "git", "rev-parse", "--is-inside-work-tree" }, {
    cwd = cwd,
    text = true,
  }):wait()
  return result.code == 0 and vim.trim(result.stdout or "") == "true"
end

---@param args string[]
---@param opts? { cwd?: string }
---@return string[]|nil, string|nil
function M.git_lines(args, opts)
  opts = opts or {}
  local cmd = vim.list_extend({ "git" }, args)
  local result = vim.system(cmd, {
    cwd = opts.cwd,
    text = true,
  }):wait()

  if result.code ~= 0 then
    local stderr = vim.trim(result.stderr or "")
    if stderr == "" then
      stderr = string.format("git %s failed with exit code %d", table.concat(args, " "), result.code)
    end
    return nil, stderr
  end

  local lines = vim.split(result.stdout or "", "\n", { trimempty = true })
  if #lines == 0 then
    return nil, nil
  end
  return lines, nil
end

---@param opts? { cwd?: string, merge_base_targets?: string[] }
---@return string|nil, string|nil
function M.merge_base(opts)
  opts = opts or {}
  local targets = opts.merge_base_targets or DEFAULT_MERGE_BASE_TARGETS
  local last_err = nil

  for _, target in ipairs(targets) do
    local result = vim.system({ "git", "merge-base", "HEAD", target }, {
      cwd = opts.cwd,
      text = true,
    }):wait()

    if result.code == 0 then
      local base = vim.trim(result.stdout or "")
      if base ~= "" then
        return base, nil
      end
    else
      local stderr = vim.trim(result.stderr or "")
      if stderr ~= "" then
        last_err = stderr
      end
    end
  end

  return nil, last_err or "Could not determine merge-base"
end

---@param scope "head"|"staged"|"branch"|"file"
---@param opts? { cwd?: string, file?: string, merge_base_targets?: string[], branch_fallback?: string }
---@return string[]|nil, string|nil
function M.diff_lines(scope, opts)
  opts = opts or {}

  if not M.in_git_repo(opts.cwd) then
    return nil, "Not inside a git repository"
  end

  if scope == "head" then
    return M.git_lines({ "--no-pager", "diff", "HEAD" }, opts)
  end

  if scope == "staged" then
    return M.git_lines({ "--no-pager", "diff", "--cached" }, opts)
  end

  if scope == "branch" then
    local base, err = M.merge_base(opts)
    if not base or base == "" then
      base = opts.branch_fallback
      if not base or base == "" then
        return nil, err or "Could not determine merge-base"
      end
    end
    return M.git_lines({ "--no-pager", "diff", base, "HEAD" }, opts)
  end

  if scope == "file" then
    if not opts.file or opts.file == "" then
      return nil, "No file path provided"
    end
    return M.git_lines({ "--no-pager", "diff", "HEAD", "--", opts.file }, opts)
  end

  return nil, string.format("Unsupported diff scope: %s", scope)
end

return M
