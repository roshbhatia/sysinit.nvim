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

local function resolve_active_model(model_names)
  local configured = vim.g.lsp_ai_model or vim.env.LSP_AI_MODEL
  if configured and configured ~= "" then
    return configured
  end

  if #model_names > 0 then
    return model_names[1]
  end

  return vim.g.lsp_ai_fallback_model or "llama3.2:3b"
end

local function build_models_table(model_names, active_model)
  local models = {}
  for _, model in ipairs(model_names) do
    models[model] = {
      type = "ollama",
      model = model,
    }
  end

  if active_model and active_model ~= "" and not models[active_model] then
    models[active_model] = {
      type = "ollama",
      model = active_model,
    }
  end

  return models
end

local function build_init_options()
  local model_names = list_ollama_models()
  local active_model = resolve_active_model(model_names)
  if not vim.g.lsp_ai_model or vim.g.lsp_ai_model == "" then
    vim.g.lsp_ai_model = active_model
  end

  local options = {
    -- Use empty_dict so file_store is encoded as an object.
    memory = {
      file_store = vim.empty_dict(),
    },
    models = build_models_table(model_names, active_model),
    actions = {
      {
        trigger = "!C",
        action_display_name = "Complete",
        model = active_model,
        parameters = {
          max_context = 4096,
          max_tokens = 4096,
          system = 'You are an AI coding assistant. Your task is to complete code snippets. The user\'s cursor position is marked by "<CURSOR>". Follow these steps:\n\n1. Analyze the code context and the cursor position.\n2. Provide your chain of thought reasoning, wrapped in <reasoning> tags.\n3. Determine the appropriate code to complete the current thought.\n4. Replace "<CURSOR>" with the necessary code.\n5. Wrap your code solution in <answer> tags.\n\nYour response should always include both the reasoning and the answer.',
          messages = {
            {
              role = "user",
              content = "{CODE}",
            },
          },
        },
        post_process = {
          extractor = "(?s)<answer>(.*?)</answer>",
        },
      },
      {
        trigger = "!R",
        action_display_name = "Refactor",
        model = active_model,
        parameters = {
          max_context = 4096,
          max_tokens = 4096,
          system = "You are an AI coding assistant specializing in code refactoring. Your task is to analyze the given code snippet and provide a refactored version. Follow these steps:\n\n1. Analyze the code context and structure.\n2. Identify areas for improvement.\n3. Provide your chain of thought reasoning, wrapped in <reasoning> tags.\n4. Rewrite the entire code snippet with your refactoring applied.\n5. Wrap your refactored code solution in <answer> tags.\n\nYour response should always include both the reasoning and the refactored code.",
          messages = {
            {
              role = "user",
              content = "{SELECTED_TEXT}",
            },
          },
        },
        post_process = {
          extractor = "(?s)<answer>(.*?)</answer>",
        },
      },
      {
        trigger = "!M",
        action_display_name = "Comment",
        model = active_model,
        parameters = {
          max_context = 4096,
          max_tokens = 4096,
          system = "You are an AI coding assistant specializing in code commenting. Your task is to add concise, helpful comments to the provided code without changing its behavior. Follow these steps:\n\n1. Analyze the code structure and intent.\n2. Add minimal comments that clarify non-obvious logic.\n3. Keep comments short and avoid restating obvious syntax.\n4. Return the full code with comments added.\n5. Wrap your final output in <answer> tags.\n\nYour response should always include both the reasoning and the commented code.",
          messages = {
            {
              role = "user",
              content = "{SELECTED_TEXT}",
            },
          },
        },
        post_process = {
          extractor = "(?s)<answer>(.*?)</answer>",
        },
      },
      {
        trigger = "!E",
        action_display_name = "Explain",
        model = active_model,
        parameters = {
          max_context = 4096,
          max_tokens = 4096,
          system = "You are an AI coding assistant specializing in explanations. Your task is to explain the provided code clearly and succinctly. Follow these steps:\n\n1. Summarize what the code does at a high level.\n2. Describe key steps or logic in order.\n3. Point out any noteworthy assumptions or edge cases.\n4. Keep the explanation concise and in plain language.\n5. Wrap your final explanation in <answer> tags.\n\nYour response should always include both the reasoning and the explanation.",
          messages = {
            {
              role = "user",
              content = "{SELECTED_TEXT}",
            },
          },
        },
        post_process = {
          extractor = "(?s)<answer>(.*?)</answer>",
        },
      },
      {
        trigger = "!S",
        action_display_name = "Simplify",
        model = active_model,
        parameters = {
          max_context = 4096,
          max_tokens = 4096,
          system = "You are an AI coding assistant specializing in simplification. Your task is to rewrite the provided code to be simpler while preserving behavior. Follow these steps:\n\n1. Identify unnecessary complexity or repetition.\n2. Simplify control flow and naming where appropriate.\n3. Keep the output idiomatic for the language.\n4. Return the full simplified code.\n5. Wrap your final output in <answer> tags.\n\nYour response should always include both the reasoning and the simplified code.",
          messages = {
            {
              role = "user",
              content = "{SELECTED_TEXT}",
            },
          },
        },
        post_process = {
          extractor = "(?s)<answer>(.*?)</answer>",
        },
      },
    },
  }

  -- Encode/decode to preserve object shape (avoids file_store as array).
  return vim.fn.json_decode(vim.fn.json_encode(options))
end

local base_config = {
  cmd = { "lsp-ai", "--stdio" },
  filetypes = {
    "asciidoc",
    "c",
    "cpp",
    "cs",
    "gitcommit",
    "go",
    "html",
    "java",
    "javascript",
    "lua",
    "markdown",
    "nix",
    "python",
    "ruby",
    "rust",
    "swift",
    "toml",
    "typescript",
    "typescriptreact",
    "haskell",
    "cmake",
    "typst",
    "php",
    "dart",
    "clojure",
    "sh",
  },
  root_markers = { ".git" },
}

local function build_config()
  local config = vim.tbl_deep_extend("force", base_config, neoconf.get("lsp_ai") or {})
  config.init_options = build_init_options()
  return config
end

local function restart_lsp_ai()
  if vim.fn.exists(":LspRestart") == 2 then
    vim.cmd("LspRestart lsp_ai")
    return
  end

  if vim.fn.exists(":LspStop") == 2 and vim.fn.exists(":LspStart") == 2 then
    vim.cmd("LspStop lsp_ai")
    vim.cmd("LspStart lsp_ai")
    return
  end

  for _, client in ipairs(vim.lsp.get_clients({ name = "lsp_ai" })) do
    client.stop()
  end

  vim.defer_fn(function()
    if vim.lsp.enable then
      vim.lsp.enable("lsp_ai")
    end
  end, 100)
end

local function set_active_model(model)
  if not model or model == "" then
    return
  end

  vim.g.lsp_ai_model = model
  if type(vim.lsp.config) == "function" then
    vim.lsp.config("lsp_ai", build_config())
  end
  restart_lsp_ai()
  vim.notify(("LSP-AI model set to %s"):format(model))
end

local function select_active_model()
  local models = list_ollama_models()
  if #models == 0 then
    vim.notify("No Ollama models found via `ollama ls`.", vim.log.levels.WARN)
    return
  end

  vim.ui.select(models, { prompt = "LSP-AI model" }, function(choice)
    if choice then
      set_active_model(choice)
    end
  end)
end

if vim.fn.exists(":LspAiModel") == 0 then
  vim.api.nvim_create_user_command("LspAiModel", function(opts)
    if opts.args ~= "" then
      set_active_model(opts.args)
      return
    end

    select_active_model()
  end, {
    nargs = "?",
    complete = function(arg_lead)
      local models = list_ollama_models()
      if arg_lead == "" then
        return models
      end

      return vim.tbl_filter(function(item)
        return item:sub(1, #arg_lead) == arg_lead
      end, models)
    end,
  })
end

return build_config()
