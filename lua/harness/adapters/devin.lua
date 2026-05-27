return require("harness.adapters._shared").raw_cli_adapter({
  name = "devin",
  label = "󰚩  Devin",
  cmd = "devin",
  options_schema = {
    { name = "continue", flag = "--continue", kind = "toggle" },
    { name = "sandbox", flag = "--sandbox", kind = "toggle" },
    {
      name = "permission_mode",
      flag = "--permission-mode",
      kind = "value",
      prompt = "Permission mode (auto, dangerous)",
    },
    {
      name = "resume",
      flag = "--resume",
      kind = "value",
      prompt = "Resume: session ID (leave blank for interactive picker via -r alone)",
    },
    {
      name = "respect_workspace_trust",
      flag = "--respect-workspace-trust",
      kind = "value",
      prompt = "Respect workspace trust (true, false)",
    },
    {
      name = "model",
      flag = "--model",
      kind = "value",
      prompt = "Model (e.g. claude-sonnet-4, claude-opus-4.6, opus, codex)",
    },
    { name = "prompt_file", flag = "--prompt-file", kind = "value", prompt = "Path to prompt file" },
    { name = "agent_config", flag = "--agent-config", kind = "value", prompt = "Path to agent config (JSON/YAML)" },
    { name = "config", flag = "--config", kind = "value", prompt = "Path to config file" },
  },
})
