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
        add_comment = { lhs = "<localleader>gc", desc = "Add PR comment" },
        review_start = { lhs = "<localleader>gS", desc = "Start a new review" },
        review_resume = { lhs = "<localleader>gR", desc = "Resume a pending review" },
      },
      review_diff = {
        add_review_comment = { lhs = "<localleader>gc", desc = "Comment on selected lines", mode = { "n", "x" } },
        add_review_suggestion = { lhs = "<localleader>gs", desc = "Suggest a change", mode = { "n", "x" } },
        submit_review = { lhs = "<localleader>gv", desc = "Submit review" },
        discard_review = { lhs = "<localleader>gD", desc = "Discard pending review" },
        focus_files = { lhs = "<localleader>de", desc = "Focus files" },
        toggle_files = { lhs = "<localleader>db", desc = "Toggle files" },
        review_commits = { lhs = "<localleader>gh", desc = "Review commits" },
      },
      file_panel = {
        submit_review = { lhs = "<localleader>gv", desc = "Submit review" },
        discard_review = { lhs = "<localleader>gD", desc = "Discard pending review" },
        focus_files = { lhs = "<localleader>de", desc = "Focus files" },
        toggle_files = { lhs = "<localleader>db", desc = "Toggle files" },
        review_commits = { lhs = "<localleader>gh", desc = "Review commits" },
      },
      review_thread = {
        add_comment = { lhs = "<localleader>gc", desc = "Reply to thread" },
        resolve_thread = { lhs = "<localleader>gt", desc = "Resolve thread" },
        unresolve_thread = { lhs = "<localleader>gT", desc = "Reopen thread" },
      },
    },
  })
  vim.api.nvim_create_user_command("PRReview", function(args)
    M.open(args.args, args.bang)
  end, { nargs = 1, bang = true, desc = "Browse a GitHub PR diff; ! opens its discussion" })
  vim.keymap.set("n", "<localleader>gr", M.start, { desc = "Start or resume GitHub review" })
  vim.keymap.set("n", "<localleader>gv", "<cmd>Octo review submit<cr>", { desc = "Submit GitHub review" })
  vim.keymap.set("n", "<localleader>gq", "<cmd>Octo review close<cr>", { desc = "Close GitHub review" })
end

return M
