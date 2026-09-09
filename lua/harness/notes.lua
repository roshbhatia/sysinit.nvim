local notes = require("agent_notes")
local setup = notes.setup
notes.setup = function(opts)
  setup(vim.tbl_extend("force", {
    agents = function()
      return require("harness.launch").all()
    end,
  }, opts or {}))
end
return notes
