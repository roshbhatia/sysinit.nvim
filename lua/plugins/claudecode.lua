return {
  {
    "coder/claudecode.nvim",
    lazy = true,
    opts = {
      -- neph's claude-peer adapter calls start()/stop() on demand via the session
      -- lifecycle; disable auto-start so claudecode doesn't race with neph's init.
      auto_start = false,
    },
  },
}
