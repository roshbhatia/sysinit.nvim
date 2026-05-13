return require("harness.adapters._shared").raw_cli_adapter({
  name = "codex",
  label = "Codex",
  cmd = "codex",
  options_schema = {
    { name = "dangerous", flag = "--dangerously-bypass-approvals-and-sandbox", kind = "toggle" },
    { name = "search",    flag = "--search",                                    kind = "toggle" },
    { name = "model",     flag = "--model",                                     kind = "value", prompt = "Model" },
  },
})
