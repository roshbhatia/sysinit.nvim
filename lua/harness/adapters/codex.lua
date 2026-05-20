return require("harness.adapters._shared").raw_cli_adapter({
  name = "codex",
  label = "󱗿  Codex",
  cmd = "codex",
  options_schema = {
    { name = "dangerous", flag = "--dangerously-bypass-approvals-and-sandbox", kind = "toggle" },
    { name = "search", flag = "--search", kind = "toggle" },
    { name = "oss", flag = "--oss", kind = "toggle" },
    {
      name = "ask_for_approval",
      flag = "--ask-for-approval",
      kind = "value",
      prompt = "Approval (untrusted, on-failure, on-request, never)",
    },
    {
      name = "sandbox",
      flag = "--sandbox",
      kind = "value",
      prompt = "Sandbox (read-only, workspace-write, danger-full-access)",
    },
    { name = "model", flag = "--model", kind = "value", prompt = "Model" },
  },
})
