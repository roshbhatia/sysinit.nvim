local busted = require("plenary.busted")
local assert = require("luassert")

busted.describe("GitHub review entry", function()
  local originals
  local calls
  busted.before_each(function()
    originals = {}
    for _, name in ipairs({ "octo", "octo.reviews", "octo.utils", "harness.github" }) do
      originals[name] = package.loaded[name]
      package.loaded[name] = nil
    end
    calls = { browse = 0, start = 0 }
    package.loaded["octo"] = {
      setup = function(config)
        calls.config = config
      end,
    }
    package.loaded["octo.utils"] = {
      get_current_buffer = function()
        return {
          isPullRequest = function()
            return true
          end,
        }
      end,
    }
    package.loaded["octo.reviews"] = {
      browse_review = function()
        calls.browse = calls.browse + 1
      end,
      get_current_review = function()
        return calls.review
      end,
      start_or_resume_review = function()
        calls.start = calls.start + 1
      end,
    }
    vim.api.nvim_create_user_command("Octo", function(args)
      calls.command = args.args
    end, { nargs = "*" })
  end)
  busted.after_each(function()
    pcall(vim.api.nvim_del_user_command, "Octo")
    pcall(vim.api.nvim_del_user_command, "PRReview")
    for _, lhs in ipairs({ ",gr", ",gv", ",gq" }) do
      pcall(vim.keymap.del, "n", lhs)
    end
    for _, name in ipairs({ "octo", "octo.reviews", "octo.utils", "harness.github" }) do
      package.loaded[name] = originals[name]
    end
  end)
  busted.it("opens the diff without starting a review", function()
    require("harness.github").setup()
    vim.cmd("PRReview https://github.com/owner/repo/pull/3")
    assert.are.equal("https://github.com/owner/repo/pull/3", calls.command)
    assert.are.equal(1, calls.browse)
    assert.are.equal(0, calls.start)
    vim.cmd("PRReview! https://github.com/owner/repo/pull/3")
    assert.are.equal(1, calls.browse)
  end)
  busted.it("starts or resumes only after the explicit review action", function()
    local integration = require("harness.github")
    integration.start()
    assert.are.equal(1, calls.start)
    calls.review = {
      start_or_resume = function()
        calls.resumed = true
      end,
    }
    integration.start()
    assert.is_true(calls.resumed)
    assert.are.equal(1, calls.start)
  end)
  busted.it("maps comments, suggestions, threads, commits, and submission", function()
    require("harness.github").setup()
    local maps = calls.config.mappings
    assert.are.equal("<localleader>gc", maps.review_diff.add_review_comment.lhs)
    assert.are.same({ "n", "x" }, maps.review_diff.add_review_comment.mode)
    assert.are.equal("<localleader>gv", maps.review_diff.submit_review.lhs)
    assert.are.equal("<localleader>gh", maps.file_panel.review_commits.lhs)
    assert.are.equal("<localleader>gc", maps.review_thread.add_comment.lhs)
    assert.are.equal("<localleader>gt", maps.review_thread.resolve_thread.lhs)
    assert.are.equal("<localleader>de", maps.review_diff.focus_files.lhs)
  end)
end)
