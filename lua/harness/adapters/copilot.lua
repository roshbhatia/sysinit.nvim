return require("harness.adapters._shared").raw_cli_adapter({
  name = "copilot",
  label = "  Copilot",
  cmd = "copilot",
  options_schema = {
    { name = "yolo", flag = "--yolo", kind = "toggle" },
    { name = "continue", flag = "--continue", kind = "toggle" },
    { name = "resume", flag = "--resume", kind = "toggle" },
    { name = "plan", flag = "--plan", kind = "toggle" },
    { name = "model", flag = "--model", kind = "value", prompt = "Model" },
  },
})
