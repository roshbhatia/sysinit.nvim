return require("harness.adapters._shared").raw_cli_adapter({
  name = "gemini",
  label = "Gemini",
  cmd = "gemini",
  options_schema = {
    { name = "yolo",    flag = "-y",      kind = "toggle" },
    { name = "sandbox", flag = "-s",      kind = "toggle" },
    { name = "resume",  flag = "-r",      kind = "value", prompt = "Resume: 'latest', index, or session name" },
    { name = "model",   flag = "--model", kind = "value", prompt = "Model" },
  },
})
