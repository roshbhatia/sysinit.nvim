local M = {}

function M.format(options)
  local opts = vim.tbl_extend("force", { bufnr = vim.api.nvim_get_current_buf(), async = false }, options or {})
  local method = opts.range and "textDocument/rangeFormatting" or "textDocument/formatting"
  local clients = vim.api.nvim_buf_call(opts.bufnr, function()
    return vim.lsp.get_clients({ bufnr = opts.bufnr, method = method })
  end)
  local priority = { ["null-ls"] = 1, nixd = 2 }
  table.sort(clients, function(a, b)
    local left, right = priority[a.name] or 3, priority[b.name] or 3
    return left < right or (left == right and a.id < b.id)
  end)
  if #clients == 0 then
    return
  end
  opts.id = clients[1].id
  vim.lsp.buf.format(opts)
end

return M
