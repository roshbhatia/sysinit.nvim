return require("harness.adapters._shared").raw_cli_adapter({
  name = "crush",
  label = "Crush",
  cmd = "crush",
  options_schema = {
    { name = "yolo",     flag = "-y", kind = "toggle" },
    { name = "continue", flag = "-C", kind = "toggle" },
    { name = "session",  flag = "-s", kind = "value", prompt = "Session id", picker_source = "crush" },
  },
})
