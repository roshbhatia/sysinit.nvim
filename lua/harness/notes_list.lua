local list = require("agent_notes.list")
local setup = list.setup
list.setup = function(opts)
  setup(vim.tbl_extend("force", {
    picker = function(spec) return Snacks.picker.pick(spec) end,
    refresh = function()
      local review = require("harness.review")
      if review.is_open() then review.refresh({ quiet = true }) end
    end,
  }, opts or {}))
end
return list
