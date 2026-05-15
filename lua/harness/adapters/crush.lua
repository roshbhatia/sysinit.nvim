return require("harness.adapters._shared").raw_cli_adapter({
  name = "crush",
  label = " Crush",
  cmd = "crush",
  options_schema = {
    { name = "yolo", flag = "--yolo", kind = "toggle" },
    { name = "continue", flag = "--continue", kind = "toggle" },
    { name = "session", flag = "--session", kind = "value", prompt = "Session id", picker_source = "crush" },
  },
})
