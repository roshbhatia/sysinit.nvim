local busted = require("plenary.busted")
local assert = require("luassert")

busted.describe("installed Octo mappings", function()
  busted.it("registers leader actions and preserves native navigation", function()
    require("harness.github").setup()
    local utils = require("octo.utils")
    local cases = {
      pull_request = { " oa", " oc", " oh", " ow", " oy" },
      review_diff = { " oc", " os", " ov", " oe", " om", "]q", "]t", "gf" },
      file_panel = { " ov", " oh", " ob", " om" },
      review_thread = { " oc", " ot", " oT" },
      submit_win = { " oa", " oc", " ox", " oq" },
    }
    for kind, keys in pairs(cases) do
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      utils.apply_mappings(kind, buf)
      for _, lhs in ipairs(keys) do
        local mapping = vim.fn.maparg(lhs, "n", false, true)
        assert.are.equal(1, mapping.buffer, kind .. ": " .. lhs)
        assert.are.equal("function", type(mapping.callback), kind .. ": " .. lhs)
      end
      if kind == "review_diff" then
        assert.are.equal(1, vim.fn.maparg(" oc", "x", false, true).buffer)
        assert.are.equal(1, vim.fn.maparg(" os", "x", false, true).buffer)
      end
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)
end)
