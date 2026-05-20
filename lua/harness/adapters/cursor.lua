return require("harness.adapters._shared").raw_cli_adapter({
  name = "cursor",
  label = "  Cursor Agent",
  cmd = "cursor-agent",
  options_schema = {
    { name = "yolo", flag = "--yolo", kind = "toggle" },
    { name = "continue", flag = "--continue", kind = "toggle" },
    { name = "resume", flag = "--resume", kind = "toggle" },
    { name = "plan", flag = "--plan", kind = "toggle" },
    { name = "worktree", flag = "--worktree", kind = "toggle" },
    { name = "skip_worktree_setup", flag = "--skip-worktree-setup", kind = "toggle" },
    { name = "trust", flag = "--trust", kind = "toggle" },
    {
      name = "mode",
      flag = "--mode",
      kind = "value",
      prompt = "Mode (plan, ask)",
    },
    {
      name = "sandbox",
      flag = "--sandbox",
      kind = "value",
      prompt = "Sandbox (enabled, disabled)",
    },
    { name = "model", flag = "--model", kind = "value", prompt = "Model (e.g. sonnet-4, gpt-5)" },
  },
})
