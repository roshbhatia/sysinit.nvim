-- Antigravity CLI (`agy`) is the Gemini-family harness; the standalone
-- `gemini` CLI is retired and is no longer installed. Flags below are read
-- from `agy --help`, not carried over from the gemini adapter — the two
-- share almost no surface (agy has no --yolo, --approval-mode, or --resume).
return require("harness.adapters._shared").raw_cli_adapter({
  name = "antigravity",
  label = "󰊭  Antigravity",
  cmd = "agy",
  options_schema = {
    { name = "continue", flag = "--continue", kind = "toggle" },
    { name = "sandbox", flag = "--sandbox", kind = "toggle" },
    { name = "dangerous", flag = "--dangerously-skip-permissions", kind = "toggle" },
    { name = "new_project", flag = "--new-project", kind = "toggle" },
    { name = "mode", flag = "--mode", kind = "value", prompt = "accept-edits|plan" },
    { name = "model", flag = "--model", kind = "value", prompt = "Model" },
    { name = "agent", flag = "--agent", kind = "value", prompt = "Agent for this session" },
    { name = "conversation", flag = "--conversation", kind = "value", prompt = "Conversation to resume" },
    { name = "project", flag = "--project", kind = "value", prompt = "Project" },
    { name = "add_dir", flag = "--add-dir", kind = "value", prompt = "Extra directory to allow" },
  },
})
