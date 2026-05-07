-- opencode.nvim — opencode CLI integration.
--
-- Server (terminal) provider:
--   auto-detect (default):
--     - wezterm pane-split when $WEZTERM_PANE is set and `wezterm` is on PATH
--     - snacks otherwise
--   override: vim.g.opencode_provider = "wezterm" | "snacks" | "auto"
--
-- The opencode plugin discovers the server out-of-band (lsof-scans for a
-- process running `opencode --port`), so any terminal that runs the command
-- works — we just have to manage the pane lifecycle.
return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    dependencies = { "folke/snacks.nvim" },
    config = function()
      local choice = vim.g.opencode_provider or "auto"
      if choice == "auto" then
        local in_wezterm = vim.env.WEZTERM_PANE ~= nil and vim.fn.executable("wezterm") == 1
        choice = in_wezterm and "wezterm" or "snacks"
      end

      local server_opts = nil
      if choice == "wezterm" then
        local ok, wezterm = pcall(require, "utils.wezterm_terminal")
        if ok then
          server_opts = wezterm.build_server_callbacks("opencode --port", {
            name = "opencode",
            percent = 0.35,
          })
        else
          vim.notify("opencode: wezterm util missing, falling back to snacks", vim.log.levels.WARN)
        end
      end

      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = server_opts, -- nil → use default (snacks)
        lsp = { enabled = true },
        events = { reload = true },
      }
    end,
    keys = {
      {
        "<leader>la",
        function() require("opencode").ask("@this: ", { submit = true }) end,
        desc = "Opencode: ask about this",
      },
      {
        "<leader>la",
        function() require("opencode").ask("@selection: ", { submit = true }) end,
        mode = "x",
        desc = "Opencode: ask about selection",
      },
      {
        "<leader>ll",
        function() require("opencode").toggle() end,
        desc = "Opencode: toggle",
      },
      {
        "<leader>ln",
        function() require("opencode").command("session.new") end,
        desc = "Opencode: new session",
      },
      {
        "<leader>lS",
        function() require("opencode").command("session.interrupt") end,
        desc = "Opencode: interrupt session",
      },
      {
        "<leader>ls",
        function() require("opencode").select_session() end,
        desc = "Opencode: select session",
      },
      {
        "<leader>lp",
        function() require("opencode").select() end,
        desc = "Opencode: quick action",
      },
      {
        "<leader>le",
        function() require("opencode").prompt("explain") end,
        desc = "Opencode: explain",
      },
      {
        "<leader>lr",
        function() require("opencode").prompt("review") end,
        desc = "Opencode: review",
      },
      {
        "<leader>lf",
        function() require("opencode").prompt("fix") end,
        desc = "Opencode: fix diagnostics",
      },
      {
        "<leader>li",
        function() require("opencode").prompt("implement") end,
        desc = "Opencode: implement",
      },
      {
        "<leader>lt",
        function() require("opencode").prompt("test") end,
        desc = "Opencode: add tests",
      },
      {
        "<leader>lc",
        function() require("opencode").command("session.compact") end,
        desc = "Opencode: compact session",
      },
      {
        "<leader>lA",
        function() require("opencode").command("agent.cycle") end,
        desc = "Opencode: cycle agent",
      },
    },
  },
}
