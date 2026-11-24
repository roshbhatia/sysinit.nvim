local function changes(command)
  require("sysinit_workbench.changes").open({ program = "changes", args = command.fargs })
end

vim.api.nvim_create_user_command("Changes", changes, { nargs = "*" })
vim.api.nvim_create_user_command("SysinitChanges", changes, { nargs = "*" })

vim.api.nvim_create_user_command("Traces", function(command)
  local args = command.fargs
  if #args == 1 and not vim.startswith(args[1], "-") then
    args = { "--session", args[1] }
  end
  require("sysinit_workbench.traces").open({ program = "traces", args = args })
end, { nargs = "*" })

vim.api.nvim_create_user_command("SysinitAgentReview", function()
  require("sysinit_workbench.review").open()
end, {})
