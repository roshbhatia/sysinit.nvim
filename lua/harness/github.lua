local M = {}

function M.start()
  local reviews = require("octo.reviews")
  local review = reviews.get_current_review()
  if review then
    review:start_or_resume()
  else
    reviews.start_or_resume_review()
  end
end

function M.open(url, overview)
  if not url:match("^https://github%.com/[%w%-]+/[%w_.%-]+/pull/%d+$") then
    vim.notify("Expected a GitHub PR URL", vim.log.levels.ERROR)
    return
  end
  if vim.v.vim_did_enter == 0 then
    vim.g.sysinit_pr_review = true
  end
  vim.cmd("Octo " .. url)
  if overview then
    return
  end
  local target = vim.api.nvim_get_current_buf()
  local attempts = 0
  local function browse()
    if not vim.api.nvim_buf_is_valid(target) or vim.api.nvim_get_current_buf() ~= target then
      return
    end
    local buffer = require("octo.utils").get_current_buffer()
    if buffer and buffer:isPullRequest() then
      require("octo.reviews").browse_review()
      return
    end
    attempts = attempts + 1
    if attempts >= 300 then
      vim.notify("PR data did not load; use :Octo review browse after it loads", vim.log.levels.ERROR)
      return
    end
    vim.defer_fn(browse, 100)
  end
  browse()
end

function M.setup()
  require("octo").setup({
    picker = "default",
    enable_builtin = true,
    default_to_https = true,
    suppress_missing_scope = { projects_v2 = true },
    mappings = {
      pull_request = {
        approve_pr = { lhs = "<leader>oa", desc = "Approve PR" },
        list_commits = { lhs = "<leader>oh", desc = "List PR commits" },
        list_changed_files = { lhs = "<leader>of", desc = "List changed files" },
        open_in_browser = { lhs = "<leader>ow", desc = "Open PR in browser" },
        copy_url = { lhs = "<leader>oy", desc = "Copy PR URL" },
        add_comment = { lhs = "<leader>oc", desc = "Add PR comment" },
        review_start = { lhs = "<leader>oS", desc = "Start a new review" },
        review_resume = { lhs = "<leader>oR", desc = "Resume a pending review" },
      },
      review_diff = {
        toggle_viewed = { lhs = "<leader>om", desc = "Mark file viewed" },
        add_review_comment = { lhs = "<leader>oc", desc = "Comment on selected lines", mode = { "n", "x" } },
        add_review_suggestion = { lhs = "<leader>os", desc = "Suggest a change", mode = { "n", "x" } },
        submit_review = { lhs = "<leader>ov", desc = "Submit review" },
        discard_review = { lhs = "<leader>oD", desc = "Discard pending review" },
        focus_files = { lhs = "<leader>oe", desc = "Focus files" },
        toggle_files = { lhs = "<leader>ob", desc = "Toggle files" },
        review_commits = { lhs = "<leader>oh", desc = "Review commits" },
      },
      file_panel = {
        toggle_viewed = { lhs = "<leader>om", desc = "Mark file viewed" },
        submit_review = { lhs = "<leader>ov", desc = "Submit review" },
        discard_review = { lhs = "<leader>oD", desc = "Discard pending review" },
        focus_files = { lhs = "<leader>oe", desc = "Focus files" },
        toggle_files = { lhs = "<leader>ob", desc = "Toggle files" },
        review_commits = { lhs = "<leader>oh", desc = "Review commits" },
      },
      review_thread = {
        add_comment = { lhs = "<leader>oc", desc = "Reply to thread" },
        resolve_thread = { lhs = "<leader>ot", desc = "Resolve thread" },
        unresolve_thread = { lhs = "<leader>oT", desc = "Reopen thread" },
      },
      submit_win = {
        approve_review = { lhs = "<leader>oa", desc = "Submit approval", mode = { "n" } },
        comment_review = { lhs = "<leader>oc", desc = "Submit comment review", mode = { "n" } },
        request_changes = { lhs = "<leader>ox", desc = "Submit requested changes", mode = { "n" } },
        close_review_tab = { lhs = "<leader>oq", desc = "Close submission form", mode = { "n" } },
      },
    },
  })
  vim.api.nvim_create_user_command("PRReview", function(args)
    M.open(args.args, args.bang)
  end, { nargs = 1, bang = true, desc = "Browse a GitHub PR diff; ! opens its discussion" })
end

function M.keys()
  return {
    { "<leader>op", "<cmd>Octo pr list<cr>", desc = "List GitHub PRs" },
    { "<leader>oo", "<cmd>Octo pr edit<cr>", desc = "Open current GitHub PR" },
    { "<leader>od", "<cmd>Octo review browse<cr>", desc = "Browse PR diff and threads" },
    { "<leader>or", M.start, desc = "Start or resume GitHub review" },
    { "<leader>ov", "<cmd>Octo review submit<cr>", desc = "Open review submission form" },
    { "<leader>oq", "<cmd>Octo review close<cr>", desc = "Close GitHub review" },
  }
end

return M
