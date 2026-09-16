vim.api.nvim_create_user_command("Wsudo", function()
  local file = vim.fn.expand("%:p")
  if file == "" or vim.bo.buftype ~= "" then
    vim.notify("Wsudo requires a named file buffer", vim.log.levels.ERROR)
    return
  end
  local cmd = "silent write !sudo tee -- " .. vim.fn.shellescape(file, 1) .. " > /dev/null"
  local ok, err = pcall(vim.api.nvim_command, cmd)
  if not ok or vim.v.shell_error ~= 0 then
    vim.notify("Wsudo failed; buffer retained: " .. tostring(err or vim.v.shell_error), vim.log.levels.ERROR)
    return
  end
  vim.api.nvim_command("edit!")
end, {
  desc = "Save current buffer with sudo",
})
