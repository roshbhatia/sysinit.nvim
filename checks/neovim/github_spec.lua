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
  busted.it("keeps startup review windows out of automatic sessions", function()
    local spec = dofile(vim.env.SYSINIT_NVIM_CONFIG .. "/lua/plugins/auto-session.lua")
    local previous = vim.g.sysinit_pr_review
    vim.g.sysinit_pr_review = true
    assert.is_false(spec.opts.pre_restore_cmds[1]())
    assert.is_false(spec.opts.pre_save_cmds[1]())
    vim.g.sysinit_pr_review = previous
  end)
  busted.it("maps comments, suggestions, threads, commits, and submission", function()
    require("harness.github").setup()
    local maps = calls.config.mappings
    assert.are.equal("<leader>oc", maps.review_diff.add_review_comment.lhs)
    assert.are.same({ "n", "x" }, maps.review_diff.add_review_comment.mode)
    assert.are.equal("<leader>ov", maps.review_diff.submit_review.lhs)
    assert.are.equal("<leader>oh", maps.file_panel.review_commits.lhs)
    assert.are.equal("<leader>oc", maps.review_thread.add_comment.lhs)
    assert.are.equal("<leader>ot", maps.review_thread.resolve_thread.lhs)
    assert.are.equal("<leader>oe", maps.review_diff.focus_files.lhs)
    assert.are.equal("<leader>oa", maps.pull_request.approve_pr.lhs)
    assert.are.equal("<leader>oa", maps.submit_win.approve_review.lhs)
    assert.are.equal("<leader>oc", maps.submit_win.comment_review.lhs)
    assert.are.equal("<leader>ox", maps.submit_win.request_changes.lhs)
    assert.are.same({ "n" }, maps.submit_win.approve_review.mode)
    for _, group in pairs(maps) do
      local used = {}
      for _, mapping in pairs(group) do
        assert.is_nil(used[mapping.lhs], "duplicate Octo key: " .. mapping.lhs)
        used[mapping.lhs] = true
      end
    end
  end)
  busted.it("exposes review entry keys before Octo loads", function()
    local spec = dofile(vim.env.SYSINIT_NVIM_CONFIG .. "/lua/plugins/github.lua")[1]
    local keys = {}
    for _, mapping in ipairs(spec.keys()) do
      keys[mapping[1]] = mapping[2]
    end
    assert.are.equal("<cmd>Octo review browse<cr>", keys["<leader>od"])
    assert.are.equal("<cmd>Octo pr edit<cr>", keys["<leader>oo"])
    assert.are.equal("<cmd>Octo review submit<cr>", keys["<leader>ov"])
    keys["<leader>or"]()
    assert.are.equal(1, calls.start)
  end)
end)
