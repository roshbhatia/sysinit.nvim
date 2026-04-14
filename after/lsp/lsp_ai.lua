-- lsp-ai: AI coding assistant LSP
-- Primary model: Anthropic Claude (when ANTHROPIC_API_KEY is set)
-- Fallback: Ollama (first available model)
-- Per-project overrides: neoconf keys lsp_ai.active_model / lsp_ai.claude_model
local neoconf = require("neoconf")

local function list_ollama_models()
  if vim.fn.executable("ollama") ~= 1 then
    return {}
  end
  local lines = vim.fn.systemlist({ "ollama", "ls" })
  if vim.v.shell_error ~= 0 then
    return {}
  end
  local models = {}
  for _, line in ipairs(lines) do
    local name = line:match("^(%S+)")
    if name and name ~= "NAME" then
      table.insert(models, name)
    end
  end
  return models
end

local function build_init_options()
  local nc = neoconf.get("lsp_ai") or {}
  local models = {}

  -- Anthropic: prefer when API key is available
  if vim.env.ANTHROPIC_API_KEY and vim.env.ANTHROPIC_API_KEY ~= "" then
    models["claude"] = {
      type = "anthropic",
      model = nc.claude_model or "claude-sonnet-4-6",
      api_key_env_var = "ANTHROPIC_API_KEY",
    }
  end

  -- Ollama: register all locally available models
  for _, name in ipairs(list_ollama_models()) do
    models[name] = { type = "ollama", model = name }
  end

  -- Resolve active model: neoconf > global > env > claude > first ollama > fallback
  local active = nc.active_model
    or vim.g.lsp_ai_model
    or vim.env.LSP_AI_MODEL
    or (models["claude"] and "claude")
    or next(models)
    or "llama3.2:3b"

  if not models[active] then
    models[active] = { type = "ollama", model = active }
  end

  vim.g.lsp_ai_model = active

  local opts = {
    memory = { file_store = vim.empty_dict() },
    models = models,
    actions = {
      {
        trigger = "!C",
        action_display_name = "Complete",
        model = active,
        parameters = {
          max_context = 4096,
          max_tokens = 4096,
          system = 'Complete the code at "<CURSOR>". Return only the replacement for "<CURSOR>" in <answer> tags.',
          messages = { { role = "user", content = "{CODE}" } },
        },
        post_process = { extractor = "(?s)<answer>(.*?)</answer>" },
      },
      {
        trigger = "!R",
        action_display_name = "Refactor",
        model = active,
        parameters = {
          max_context = 4096,
          max_tokens = 4096,
          system = "Refactor the provided code for clarity and correctness without changing behavior. Return the result in <answer> tags.",
          messages = { { role = "user", content = "{SELECTED_TEXT}" } },
        },
        post_process = { extractor = "(?s)<answer>(.*?)</answer>" },
      },
      {
        trigger = "!E",
        action_display_name = "Explain",
        model = active,
        parameters = {
          max_context = 4096,
          max_tokens = 1024,
          system = "Explain the provided code clearly and concisely. Wrap your explanation in <answer> tags.",
          messages = { { role = "user", content = "{SELECTED_TEXT}" } },
        },
        post_process = { extractor = "(?s)<answer>(.*?)</answer>" },
      },
      {
        trigger = "!S",
        action_display_name = "Simplify",
        model = active,
        parameters = {
          max_context = 4096,
          max_tokens = 4096,
          system = "Simplify the provided code while preserving behavior. Return the result in <answer> tags.",
          messages = { { role = "user", content = "{SELECTED_TEXT}" } },
        },
        post_process = { extractor = "(?s)<answer>(.*?)</answer>" },
      },
    },
  }

  -- json round-trip: preserves file_store as object not array
  return vim.fn.json_decode(vim.fn.json_encode(opts))
end

local function build_config()
  return vim.tbl_deep_extend("force", {
    cmd = { "lsp-ai", "--stdio" },
    filetypes = {
      "c", "cpp", "cs", "clojure", "cmake", "dart", "go", "haskell",
      "html", "java", "javascript", "lua", "markdown", "nix", "php",
      "python", "ruby", "rust", "sh", "swift", "toml", "typescript",
      "typescriptreact", "typst",
    },
    root_markers = { ".git" },
    init_options = build_init_options(),
  }, {})
end

-- LspAiModel: switch active model at runtime (no args → picker)
if vim.fn.exists(":LspAiModel") == 0 then
  vim.api.nvim_create_user_command("LspAiModel", function(opts)
    local function apply(model)
      vim.g.lsp_ai_model = model
      vim.lsp.config("lsp_ai", build_config())
      for _, client in ipairs(vim.lsp.get_clients({ name = "lsp_ai" })) do
        client.stop()
      end
      vim.defer_fn(function()
        vim.lsp.enable("lsp_ai")
      end, 100)
      vim.notify(("lsp-ai: model → %s"):format(model))
    end

    if opts.args ~= "" then
      apply(opts.args)
      return
    end

    local choices = {}
    if vim.env.ANTHROPIC_API_KEY and vim.env.ANTHROPIC_API_KEY ~= "" then
      table.insert(choices, "claude")
    end
    for _, m in ipairs(list_ollama_models()) do
      table.insert(choices, m)
    end

    if #choices == 0 then
      vim.notify("lsp-ai: no models available", vim.log.levels.WARN)
      return
    end

    vim.ui.select(choices, { prompt = "lsp-ai model" }, function(choice)
      if choice then
        apply(choice)
      end
    end)
  end, {
    nargs = "?",
    complete = function(arg_lead)
      local choices = {}
      if vim.env.ANTHROPIC_API_KEY and vim.env.ANTHROPIC_API_KEY ~= "" then
        table.insert(choices, "claude")
      end
      for _, m in ipairs(list_ollama_models()) do
        table.insert(choices, m)
      end
      if arg_lead == "" then
        return choices
      end
      return vim.tbl_filter(function(m)
        return m:sub(1, #arg_lead) == arg_lead
      end, choices)
    end,
  })
end

return build_config()
