-- diff-review.lua
-- Focused diff-review workflow for agent-assisted code review.
--
-- Core idea: load a git diff into a scratch buffer (filetype=diff) then hand
-- it straight to avante so the agent reviews it as first-class code context.
-- Also wires up snacks.picker diff views for fast file navigation.

local function with_avante(buf, prompt)
  vim.api.nvim_set_current_buf(buf)
  -- give avante a tick to register the new buffer as its code target
  vim.schedule(function()
    require("avante.api").ask({ question = prompt })
  end)
end

--- Open a scratch diff buffer containing `lines`, then ask avante `prompt`.
local function open_diff_for_review(lines, label, prompt)
  if not lines or #lines == 0 then
    vim.notify("[diff-review] No diff output — nothing to review", vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "diff"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_name(buf, label)

  -- open in a horizontal split so the diff is visible alongside avante's panel
  vim.cmd("split")
  vim.api.nvim_set_current_buf(buf)

  with_avante(buf, prompt)
end

--- Run a git command and return stdout split into lines (or nil on failure).
local function git(args)
  local result = vim.system({ "git" }, { text = true }):wait()
  -- check we're in a git repo first
  if result.code ~= 0 then
    vim.notify("[diff-review] Not inside a git repository", vim.log.levels.WARN)
    return nil
  end
  local cmd = vim.list_extend({ "git" }, args)
  local out = vim.system(cmd, { text = true }):wait()
  if out.code ~= 0 and out.stdout == "" then
    return nil
  end
  local lines = vim.split(out.stdout or "", "\n", { trimempty = true })
  return #lines > 0 and lines or nil
end

local REVIEW_PROMPT = "Review this diff carefully. "
  .. "Identify any bugs, logic errors, security issues, missing edge-cases, "
  .. "or places where the intent of the change is unclear. "
  .. "Be concise and specific — cite line numbers where relevant."

local HUNK_PROMPT = "Review this specific hunk. "
  .. "What does it change, is the change correct, and are there any issues?"

return {
  {
    -- virtual plugin — no remote source, just keymaps wired through lazy
    dir = vim.fn.stdpath("config"),
    name = "diff-review",
    lazy = false,
    dependencies = {
      "yetone/avante.nvim",
      "folke/snacks.nvim",
      "lewis6991/gitsigns.nvim",
    },
    keys = {
      -- ── Snacks pickers ──────────────────────────────────────────────────────
      {
        "<leader>rr",
        function()
          -- all unstaged + staged changes, side-by-side diff preview
          require("snacks").picker.git_diff()
        end,
        desc = "Review: browse all changed files",
      },
      {
        "<leader>rs",
        function()
          require("snacks").picker.git_diff({ staged = true })
        end,
        desc = "Review: browse staged changes",
      },
      {
        "<leader>rf",
        function()
          -- changed files in the current branch vs main/master
          local base = vim.fn.systemlist("git merge-base HEAD origin/HEAD 2>/dev/null")[1]
            or vim.fn.systemlist("git merge-base HEAD origin/main 2>/dev/null")[1]
            or "HEAD~1"
          require("snacks").picker.git_diff({ base = base })
        end,
        desc = "Review: browse branch diff vs origin",
      },

      -- ── Avante review ───────────────────────────────────────────────────────
      {
        "<leader>ra",
        function()
          -- all uncommitted changes (staged + unstaged)
          local lines = git({ "--no-pager", "diff", "HEAD" })
          open_diff_for_review(lines, "diff://review-all", REVIEW_PROMPT)
        end,
        desc = "Review: ask agent to review all changes (HEAD)",
      },
      {
        "<leader>rS",
        function()
          -- staged only
          local lines = git({ "--no-pager", "diff", "--cached" })
          open_diff_for_review(lines, "diff://review-staged", REVIEW_PROMPT)
        end,
        desc = "Review: ask agent to review staged changes",
      },
      {
        "<leader>rb",
        function()
          -- current branch vs origin/HEAD
          local base = vim.trim(
            vim.fn.system("git merge-base HEAD origin/HEAD 2>/dev/null")
              or vim.fn.system("git merge-base HEAD origin/main 2>/dev/null")
              or ""
          )
          if base == "" then
            vim.notify("[diff-review] Could not determine merge-base", vim.log.levels.WARN)
            return
          end
          local lines = git({ "--no-pager", "diff", base, "HEAD" })
          open_diff_for_review(lines, "diff://review-branch", REVIEW_PROMPT)
        end,
        desc = "Review: ask agent to review entire branch diff",
      },
      {
        "<leader>rF",
        function()
          -- current file vs HEAD
          local file = vim.fn.expand("%:p")
          if file == "" then
            vim.notify("[diff-review] No file in current buffer", vim.log.levels.WARN)
            return
          end
          local lines = git({ "--no-pager", "diff", "HEAD", "--", file })
          local label = "diff://review-" .. vim.fn.expand("%:t")
          open_diff_for_review(lines, label, REVIEW_PROMPT)
        end,
        desc = "Review: ask agent to review current file diff",
      },
      {
        "<leader>rh",
        function()
          -- current hunk under cursor via gitsigns
          local gs = require("gitsigns")
          local hunks = gs.get_hunks and gs.get_hunks()
          if not hunks or #hunks == 0 then
            vim.notify("[diff-review] No hunks in buffer", vim.log.levels.WARN)
            return
          end
          -- find the hunk whose added range contains the cursor line
          local cursor_line = vim.fn.line(".")
          local hunk
          for _, h in ipairs(hunks) do
            local start = h.added.start
            local finish = start + math.max(h.added.count - 1, 0)
            if cursor_line >= start and cursor_line <= finish then
              hunk = h
              break
            end
          end
          hunk = hunk or hunks[1] -- fallback: first hunk
          local lines = vim.list_extend({ hunk.head }, hunk.lines)
          open_diff_for_review(lines, "diff://review-hunk", HUNK_PROMPT)
        end,
        desc = "Review: ask agent to review current hunk",
      },
    },
  },
}
