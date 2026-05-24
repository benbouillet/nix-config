{
  config,
  ...
}:
{
  sops.secrets."ai/openrouter_api_key" = { };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    settings = {
      autoshare = false;
      autoupdate = false;

      ###############
      ## PROVIDERS
      ###############
      provider = {
        "amazon-bedrock" = {
          options = {
            region = "eu-west-3";
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
    agents = ./agents;
    commands = ./commands;
  };

  xdg.configFile."opencode/opencode.json".force = true;

  programs.zsh.shellAliases = {
    oc = "opencode";
  };
}
