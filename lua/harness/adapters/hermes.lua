-- Launch `hermes chat`, not bare `hermes`. Bare hermes is a subcommand
-- dispatcher whose top-level parser accepts only --resume/--continue/
-- --worktree/--skills/--yolo/--pass-session-id; --model, --provider, and
-- --toolsets exist solely under the `chat` subcommand, so passing them to bare
-- hermes exits with a usage error instead of launching.
--
-- Removed here because they exist in neither parser: --tui, --accept-hooks,
-- --ignore-rules, --ignore-user-config. Model and provider defaults are
-- otherwise managed by the `hermes model` subcommand.
return require("harness.adapters._shared").raw_cli_adapter({
  name = "hermes",
  label = "☤  Hermes",
  cmd = "hermes chat",
  options_schema = {
    { name = "yolo", flag = "--yolo", kind = "toggle" },
    { name = "worktree", flag = "--worktree", kind = "toggle" },
    { name = "continue", flag = "--continue", kind = "toggle" },
    { name = "pass-session-id", flag = "--pass-session-id", kind = "toggle" },
    { name = "checkpoints", flag = "--checkpoints", kind = "toggle" },
    { name = "quiet", flag = "--quiet", kind = "toggle" },
    { name = "verbose", flag = "--verbose", kind = "toggle" },
    { name = "resume", flag = "--resume", kind = "value", prompt = "Resume: session ID or title" },
    { name = "model", flag = "--model", kind = "value", prompt = "Model (e.g. anthropic/claude-sonnet-5)" },
    { name = "provider", flag = "--provider", kind = "value", prompt = "Provider (e.g. openrouter, anthropic)" },
    { name = "toolsets", flag = "--toolsets", kind = "value", prompt = "Toolsets (comma-separated)" },
    { name = "skills", flag = "--skills", kind = "value", prompt = "Skills (comma-separated)" },
    { name = "max_turns", flag = "--max-turns", kind = "value", prompt = "Max turns" },
  },
})
