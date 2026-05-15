return require("harness.adapters._shared").raw_cli_adapter({
  name = "cursor",
  label = "  Cursor Agent",
  cmd = "cursor-agent",
  options_schema = {
    { name = "yolo", flag = "--yolo", kind = "toggle" },
    { name = "cloud", flag = "--cloud", kind = "toggle" },
    { name = "continue", flag = "--continue", kind = "toggle" },
    { name = "resume", flag = "--resume", kind = "toggle" },
    { name = "plan", flag = "--plan", kind = "toggle" },
    { name = "model", flag = "--model", kind = "value", prompt = "Model (e.g. sonnet-4, gpt-5)" },
  },
})
