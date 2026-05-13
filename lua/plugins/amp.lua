-- amp.nvim — Sourcegraph Amp IDE bridge.
--
-- amp.nvim is an IDE-bridge (LSP-ish), not a terminal manager. The
-- canonical send-path is require("amp.message").send_message(text), which
-- requires the bridge to be running (auto_start = true).
--
-- Keymaps live in lua/plugins/harness.lua under <leader>j*; routing through
-- the harness adapter (lua/harness/adapters/amp.lua) is the supported flow.
return {
  {
    "sourcegraph/amp.nvim",
    branch = "main",
    lazy = false,
    opts = {
      auto_start = true,
      log_level = "info",
    },
  },
}
