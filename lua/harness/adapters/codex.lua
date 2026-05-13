return require("harness.adapters._shared").raw_cli_adapter({
  name = "codex",
  label = "Codex",
  cmd = "codex",
  options_schema = {
    { name = "dangerous", flag = "--dangerously-bypass-approvals-and-sandbox", kind = "toggle" },
    { name = "model",     flag = "-m",                                          kind = "value", prompt = "Model" },
  },
})
