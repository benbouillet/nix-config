{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  # Wrap opencode with GCC libstdc++ for native file watcher bindings
  opencode-wrapped = pkgs.symlinkJoin {
    name = "opencode-wrapped";
    paths = [ pkgs.opencode ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --prefix LD_LIBRARY_PATH : "${pkgs.stdenv.cc.cc.lib}/lib"
    '';
  };

  MkAgent =
    {
      template,
      model,
      suffix,
    }:
    let
      raw = builtins.readFile template;
    in
    builtins.replaceStrings [ "@model@" "@subagents_suffix@" ] [ model suffix ] raw;
in
{
  sops.secrets."ai/openrouter_api_key" = { };

  home.activation = {
    installOpencodeRtk = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.rtk}/bin/rtk init -g --opencode
    '';
  };

  home.packages = [ opencode-wrapped ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = opencode-wrapped;

    settings = {
      autoshare = false;
      autoupdate = false;

      default_agent = "zeus";
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
                context = 65536;
                output = 32768;
              };
            };
            "qwen3.6-27b-thinking" = {
              name = "Qwen 3.6 27B Thinking (local)";
              limit = {
                context = 65536;
                output = 32768;
              };
            };
            "qwen3.6-27b-coding" = {
              name = "Qwen 3.6 27B Coding (local)";
              limit = {
                context = 65536;
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
                context = 131072;
                output = 32768;
              };
            };
            "qwen3.6-35b-a3b-coding" = {
              name = "Qwen 3.6 35B A3B Coding (local)";
              limit = {
                context = 65536;
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
      ## PLUGINS
      ###############
      # NOTE: vimcode TUI plugin is configured in programs.opencode.tui.plugin
      plugin = [ ];

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

      ###############
      ## SKILLS
      ###############

      ###############
      ## PERMISSIONS
      ###############
      permission = {
        skill = "deny";
      };
    };

    context = ./AGENTS.md;
    agents = {
      # argus variants
      argus = MkAgent {
        template = ./agents/argus.md.tmpl;
        model = "openrouter/deepseek/deepseek-v4-flash";
        suffix = "";
      };
      argus-work = MkAgent {
        template = ./agents/argus.md.tmpl;
        model = "amazon-bedrock/zai.glm-4.7-flash";
        suffix = "-work";
      };

      # athena variants
      athena = MkAgent {
        template = ./agents/athena.md.tmpl;
        model = "openrouter/deepseek/deepseek-v4-pro";
        suffix = "";
      };
      athena-work = MkAgent {
        template = ./agents/athena.md.tmpl;
        model = "amazon-bedrock/zai.glm-5";
        suffix = "-work";
      };

      # cerberus variants
      cerberus = MkAgent {
        template = ./agents/cerberus.md.tmpl;
        model = "llama-cpp/qwen3.6-27b-instruct";
        suffix = "";
      };
      cerberus-work = MkAgent {
        template = ./agents/cerberus.md.tmpl;
        model = "amazon-bedrock/zai.glm-4.7-flash";
        suffix = "-work";
      };

      # heracles variants
      heracles = MkAgent {
        template = ./agents/heracles.md.tmpl;
        model = "llama-cpp/qwen3.6-35b-a3b-coding";
        suffix = "";
      };
      heracles-work = MkAgent {
        template = ./agents/heracles.md.tmpl;
        model = "amazon-bedrock/minimax.minimax-m2.5";
        suffix = "-work";
      };

      # iris variants
      iris = MkAgent {
        template = ./agents/iris.md.tmpl;
        model = "llama-cpp/qwen3.6-35b-a3b-coding";
        suffix = "";
      };
      iris-work = MkAgent {
        template = ./agents/iris.md.tmpl;
        model = "amazon-bedrock/zai.glm-4.7-flash";
        suffix = "-work";
      };

      # zephyr variants
      zephyr = MkAgent {
        template = ./agents/zephyr.md.tmpl;
        model = "llama-cpp/qwen3.6-35b-a3b-instruct";
        suffix = "";
      };
      zephyr-work = MkAgent {
        template = ./agents/zephyr.md.tmpl;
        model = "amazon-bedrock/qwen/qwen3-coder-480b-a35b-instruct";
        suffix = "-work";
      };

      # zeus variants
      zeus = MkAgent {
        template = ./agents/zeus.md.tmpl;
        model = "openrouter/deepseek/deepseek-v4-flash";
        suffix = "";
      };
      zeus-work = MkAgent {
        template = ./agents/zeus.md.tmpl;
        model = "amazon-bedrock/moonshotai.kimi-k2.5";
        suffix = "-work";
      };
    };
    skills = ./skills;
    commands = ./commands;

    tui = {
      theme = "stylix";
      plugin = [
        "vimcode@git+https://github.com/oribarilan/vimcode.git#v0.8.0"
      ];
    };
  };

  xdg.configFile."opencode/opencode.json".force = true;

  programs.zsh.shellAliases = {
    oc = "opencode";
  };
}
