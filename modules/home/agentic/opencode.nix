{
  config,
  ...
}:
let
  agentNames = [
    "argus"
    "athena"
    "cerberus"
    "heracles"
    "iris"
    "zephyr"
    "zeus"
  ];

  suffixPrompt =
    suffix: text:
    builtins.replaceStrings (map (n: "`${n}`") agentNames) (map (
      n: "`${n}-${suffix}`"
    ) agentNames) text;

  mkAgentStr =
    suffix: name:
    let
      a = agents.${name};
      model = if suffix == "" then a.model.home else a.model.work;
      modelLine = if model == "" then "" else "model: ${model}\n";
      toolsSection = if a.tools == "" then "" else "\n${a.tools}";
      prompt =
        if suffix == "" then
          builtins.readFile a.prompt
        else
          suffixPrompt suffix (builtins.readFile a.prompt);
    in
    ''
      ---
      description: ${a.description}
      mode: ${a.mode}
      ${modelLine}${toolsSection}---
      ${prompt}
    '';

  agents = {
    argus = {
      description = "Codebase explorer. Read-only. Answers \"where is X?\" / \"how is Y used?\" with file:line citations. Fires searches in parallel.";
      mode = "subagent";
      model = {
        work = "amazon-bedrock/zai.glm-4.7-flash";
        home = "openrouter/deepseek/deepseek-v4-flash";
      };
      tools = ''
        tools:
          write: false
          edit: false
      '';
      prompt = ./agents/argus.md;
    };
    athena = {
      description = "Planner. Asks clarifying questions, then writes an implementation plan. Read-only on code; writes only into .plans/.";
      mode = "subagent";
      model = {
        work = "amazon-bedrock/zai.glm-5";
        home = "openrouter/deepseek/deepseek-v4-pro";
      };
      tools = ''
        tools:
          bash: false
          webfetch: false
          websearch: false
      '';
      prompt = ./agents/athena.md;
    };
    cerberus = {
      description = "Diff reviewer. Flags only blocking correctness, security, or behavior-change issues. Approval-biased.";
      mode = "subagent";
      model = {
        work = "amazon-bedrock/zai.glm-4.7-flash";
        home = "openrouter/deepseek/deepseek-v4-flash";
      };
      tools = ''
        tools:
          write: false
          edit: false
      '';
      prompt = ./agents/cerberus.md;
    };
    heracles = {
      description = "Craftsman. Implements changes end-to-end: edits, builds, tests. Owns the diff.";
      mode = "subagent";
      model = {
        work = "amazon-bedrock/qwen.qwen3-coder-next";
        home = "openrouter/deepseek/deepseek-v4-flash";
      };
      tools = "";
      prompt = ./agents/heracles.md;
    };
    iris = {
      description = "Research partner. Fans out web searches to zephyr workers, synthesizes findings into a cited answer. Owns the question; never reads pages directly.";
      mode = "primary";
      model = {
        work = "amazon-bedrock/zai.glm-4.7-flash";
        home = "openrouter/deepseek/deepseek-v4-flash";
      };
      tools = ''
        tools:
          bash: false
          write: false
          edit: false
          webfetch: false
          websearch: false
      '';
      prompt = ./agents/iris.md;
    };
    zephyr = {
      description = "Web search worker. Fetches pages, extracts what was asked for, returns a tight summary with source URLs. Spawned by iris (multi-angle research) or directly (one-off lookup).";
      mode = "subagent";
      model = {
        work = "amazon-bedrock/qwen/qwen3-coder-480b-a35b-instruct";
        # home = "llama-cpp/qwen3.6-27b-instruct";
        home = "openrouter/deepseek/deepseek-v4-flash";
      };
      tools = ''
        tools:
          write: false
          edit: false
          task: false
      '';
      prompt = ./agents/zephyr.md;
    };
    zeus = {
      description = "Master orchestrator. Plans, delegates to subagents, synthesizes results. Never implements directly.";
      mode = "primary";
      model = {
        work = "amazon-bedrock/moonshotai.kimi-k2.5";
        home = "openrouter/deepseek/deepseek-v4-flash";
      };
      tools = ''
        tools:
          write: false
          edit: false
          bash: false
          todowrite: true
      '';
      prompt = ./agents/zeus.md;
    };
  };
in
{
  sops.secrets."ai/openrouter_api_key" = { };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    settings = {
      autoshare = false;
      autoupdate = false;

      default_agent = "iris";
      model = "openrouter/deepseek/deepseek-v4-pro";
      small_model = "openrouter/deepseek/deepseek-v4-flash";
      ###############
      ## PROVIDERS
      ###############
      provider = {
        "amazon-bedrock" = {
          options = {
            region = "eu-west-2";
            profile = "ai-platform";
          };
        };
        openrouter = {
          options = {
            # baseURL = "https://openrouter.ai/api/v1";
            apiKey = "{file:${config.sops.secrets."ai/openrouter_api_key".path}}";
          };
        };
        "llama-cpp" = {
          npm = "@ai-sdk/openai-compatible";
          name = "llama-cpp (chewie)";
          options = {
            baseURL = "https://ai.r4clette.com/v1";
          };
          models = {
            "qwen3.6-27b-instruct" = {
              name = "Qwen 3.6 27B Instruct (local)";
              limit = {
                context = 131072;
                output = 32768;
              };
            };
            "qwen3.6-27b-thinking" = {
              name = "Qwen 3.6 27B Thinking (local)";
              limit = {
                context = 131072;
                output = 32768;
              };
            };
            "qwen3.6-27b-coding" = {
              name = "Qwen 3.6 27B Coding (local)";
              limit = {
                context = 131072;
                output = 32768;
              };
            };
            "qwen3.6-35b-a3b-instruct" = {
              name = "Qwen 3.6 35B A3B Instruct (local)";
              limit = {
                context = 131072;
                output = 32768;
              };
            };
            "qwen3.6-35b-a3b-thinking" = {
              name = "Qwen 3.6 35B A3B Thinking (local)";
              limit = {
                context = 262144;
                output = 32768;
              };
            };
            "qwen3.6-35b-a3b-coding" = {
              name = "Qwen 3.6 35B A3B Coding (local)";
              limit = {
                context = 262144;
                output = 32768;
              };
            };
            "gemma4-e4b-instruct" = {
              name = "Gemma 4 E4B Instruct (local)";
              limit = {
                context = 65536;
                output = 32768;
              };
            };
          };
        };
      };
      ###############
      ## MCP SERVERS
      ###############
      disabled_providers = [
        "anthropic"
        "azure-openai"
        "azure-cognitive-services"
        "baseten"
        "cerebras"
        "cloudflare-ai-gateway"
        "cortecs"
        "deepseek"
        "deep-infra"
        "fireworks-ai"
        "github-copilot"
        "google-vertex-ai"
        "groq"
        "hugging-face"
        "helicone"
        "llama.cpp"
        "io-net"
        "lmstudio"
        "moonshot-ai"
        "nebius-token-factory"
        "ollama"
        "ollama-cloud"
        "openai"
        "sap-ai-core"
        "ovhcloud-ai-endpoints"
        "together-ai"
        "venice-ai"
        "xai"
        "zai"
        "zenmux"
        "google"
      ];
      enabled_providers = [
        "openrouter"
        "amazon-bedrock"
        "llama-cpp"
      ];

      ###############
      ## MISC
      ###############
      watcher = {
        ignore = [
          "node_modules/**"
          "dist/**"
          ".git/**"
          ".terragrunt-cache/**"
        ];
      };
    };

    context = ./AGENTS.md;
    agents = builtins.listToAttrs (
      builtins.concatMap (name: [
        {
          name = name;
          value = mkAgentStr "" name;
        }
        {
          name = "${name}-work";
          value = mkAgentStr "work" name;
        }
      ]) agentNames
    );
    commands = ./commands;
  };

  xdg.configFile."opencode/opencode.json".force = true;

  programs.zsh.shellAliases = {
    oc = "opencode";
  };
}
