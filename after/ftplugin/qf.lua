vim.opt_local.number = false
vim.opt_local.wrap = false
vim.opt_local.spell = false
vim.opt_local.cursorline = true

Snacks.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, desc = "Close" })

local buf = vim.api.nvim_get_current_buf()
vim.schedule(function()
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  Snacks.keymap.set("n", "<CR>", function()
    if not pcall(function()
      require("bqf.qfwin.handler").open(false)
    end) then
      vim.cmd(".cc")
    end
  end, { buffer = buf, desc = "Open entry" })
end)
