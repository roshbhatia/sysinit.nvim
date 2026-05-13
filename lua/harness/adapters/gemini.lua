return require("harness.adapters._shared").raw_cli_adapter({
  name = "gemini",
  label = "Gemini",
  cmd = "gemini",
  options_schema = {
    { name = "resume", flag = "-r",      kind = "value", prompt = "Resume index, 'latest', or session" },
    { name = "model",  flag = "--model", kind = "value", prompt = "Model" },
  },
})
