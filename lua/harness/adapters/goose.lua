return require("harness.adapters._shared").raw_cli_adapter({
  name = "goose",
  label = "  Goose",
  cmd = "goose",
  args = { "session" },
  options_schema = {
    { name = "resume", flag = "--resume", kind = "toggle" },
    { name = "fork", flag = "--fork", kind = "toggle" },
    { name = "history", flag = "--history", kind = "toggle" },
    { name = "debug", flag = "--debug", kind = "toggle" },
    { name = "name", flag = "--name", kind = "value", prompt = "Session name", picker_source = "goose" },
  },
})
