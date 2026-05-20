return require("harness.adapters._shared").raw_cli_adapter({
  name = "gemini",
  label = "󰊭  Gemini",
  cmd = "gemini",
  options_schema = {
    { name = "yolo", flag = "--yolo", kind = "toggle" },
    { name = "sandbox", flag = "--sandbox", kind = "toggle" },
    { name = "worktree", flag = "--worktree", kind = "toggle" },
    { name = "skip_trust", flag = "--skip-trust", kind = "toggle" },
    {
      name = "approval_mode",
      flag = "--approval-mode",
      kind = "value",
      prompt = "Approval (default, auto_edit, yolo, plan)",
    },
    { name = "resume", flag = "--resume", kind = "value", prompt = "Resume: 'latest', index, or session name" },
    { name = "model", flag = "--model", kind = "value", prompt = "Model" },
  },
})
