return require("harness.adapters._shared").raw_cli_adapter({
  name = "hermes",
  label = "☤  Hermes",
  cmd = "hermes",
  options_schema = {
    { name = "yolo", flag = "--yolo", kind = "toggle" },
    { name = "worktree", flag = "--worktree", kind = "toggle" },
    { name = "tui", flag = "--tui", kind = "toggle" },
    { name = "continue", flag = "--continue", kind = "toggle" },
    { name = "accept-hooks", flag = "--accept-hooks", kind = "toggle" },
    { name = "pass-session-id", flag = "--pass-session-id", kind = "toggle" },
    { name = "ignore-rules", flag = "--ignore-rules", kind = "toggle" },
    { name = "resume", flag = "--resume", kind = "value", prompt = "Resume: session ID or title" },
    { name = "model", flag = "--model", kind = "value", prompt = "Model (e.g. anthropic/claude-sonnet-4.6)" },
    { name = "provider", flag = "--provider", kind = "value", prompt = "Provider (e.g. openrouter, anthropic)" },
    { name = "toolsets", flag = "--toolsets", kind = "value", prompt = "Toolsets (comma-separated)" },
    { name = "skills", flag = "--skills", kind = "value", prompt = "Skills (comma-separated)" },
  },
})
