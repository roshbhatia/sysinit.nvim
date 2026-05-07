-- amp.nvim — Sourcegraph Amp CLI integration. Terminal is snacks-only.
-- Built-in <leader>a* keymaps disabled; we wire <leader>i* explicitly.
return {
  {
    "sourcegraph/amp.nvim",
    dependencies = {
      "folke/snacks.nvim",
      "nvim-lua/plenary.nvim",
    },
    cmd = {
      "Amp",
      "AmpToggle",
      "AmpNew",
      "AmpContinue",
      "AmpSend",
      "AmpSendBuffer",
      "AmpSendSelection",
      "AmpAddBuffer",
      "AmpAddSelection",
      "AmpClearContext",
      "AmpStatus",
      "AmpAuth",
      "AmpThread",
      "AmpThreads",
    },
    opts = {
      keymaps = { enabled = false },
      terminal = { position = "right", size = 0.4 },
    },
    keys = {
      { "<leader>ii", function() require("amp").toggle() end,           desc = "Amp: toggle" },
      { "<leader>in", function() require("amp").new_thread() end,       desc = "Amp: new thread" },
      { "<leader>ic", function() require("amp").continue_thread() end,  desc = "Amp: continue thread" },
      { "<leader>ib", function() require("amp").send_buffer() end,      desc = "Amp: send buffer" },
      { "<leader>iB", function() require("amp").add_buffer() end,       desc = "Amp: add buffer to context" },
      { "<leader>is", function() require("amp").send_selection() end,   desc = "Amp: send selection",   mode = "v" },
      { "<leader>iS", function() require("amp").add_selection() end,    desc = "Amp: add selection",    mode = "v" },
      { "<leader>ix", function() require("amp").clear_context() end,    desc = "Amp: clear context" },
      { "<leader>it", function() require("amp").list_threads() end,     desc = "Amp: list threads" },
      { "<leader>ia", function() require("amp").auth() end,             desc = "Amp: auth" },
      { "<leader>i?", function() require("amp").status() end,           desc = "Amp: status" },
    },
  },
}
