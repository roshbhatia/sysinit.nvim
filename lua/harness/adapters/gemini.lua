return require("harness.adapters._shared").raw_cli_adapter({
  name = "gemini",
  label = "󰊭  Gemini",
  cmd = "gemini",
  options_schema = {
    { name = "yolo", flag = "--yolo", kind = "toggle" },
    { name = "sandbox", flag = "--sandbox", kind = "toggle" },
    { name = "resume", flag = "--resume", kind = "value", prompt = "Resume: 'latest', index, or session name" },
    { name = "model", flag = "--model", kind = "value", prompt = "Model" },
  },
})
