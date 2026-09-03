{
  config,
  pkgs,
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
in
{
  sops.secrets."ai/openrouter_api_key" = { };
  sops.secrets."ai/sunday_litellm_api_key" = { };
  sops.secrets."ai/sunday_n8n_api_key" = { };
  sops.secrets."ai/sunday_linear_api_key" = { };

  home.sessionVariables.LITELLM_API_KEY = "$(cat ${
    config.sops.secrets."ai/sunday_litellm_api_key".path
  })";
  home.sessionVariables.N8N_API_KEY = "$(cat ${config.sops.secrets."ai/sunday_n8n_api_key".path})";
  home.sessionVariables.LINEAR_API_KEY = "$(cat ${
    config.sops.secrets."ai/sunday_linear_api_key".path
  })";

  home.packages = [
    pkgs.graphify
    pkgs.mcp-nixos
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = opencode-wrapped;

    settings = {
      autoshare = false;
      autoupdate = false;

      default_agent = "zeus";
      model = "litellm/deepseek.deepseek-v4-pro";
      small_model = "litellm/deepseek.deepseek-v4-flash";

      skills = { };
      permission = { };

      provider = {
        # "amazon-bedrock" = {
        #   options = {
        #     region = "eu-west-2";
        #     profile = "ai-platform";
        #   };
        # };
        # openrouter = {
        #   options = {
        #     # baseURL = "https://openrouter.ai/api/v1";
        #     apiKey = "{file:${config.sops.secrets."ai/openrouter_api_key".path}}";
        #   };
        # };
        "llama-cpp" = {
          npm = "@ai-sdk/openai-compatible";
          name = "llama-cpp (chewie)";
          options = {
            baseURL = "https://ai.r4clette.com/v1";
          };
          models = {
            "qwen3.8:27b" = {
              name = "Qwen 3.8 27b (chewie)";
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
      mcp = {
        brave-search = {
          type = "remote";
          url = "https://litellm.int.sundayapp.xyz/mcp/brave_search";
          headers = {
            "x-litellm-api-key" = "Bearer {env:LITELLM_API_KEY}";
          };
        };
        nixos = {
          type = "local";
          command = [ "mcp-nixos" ];
        };
        linear = {
          type = "remote";
          url = "https://mcp.linear.app/mcp/readonly";
          headers = {
            Authorization = "Bearer {env:LINEAR_API_KEY}";
          };
        };
        # n8n = {
        #   type = "remote";
        #   url = "https://n8n.int.sundayapp.xyz/mcp-server/http";
        #   headers = {
        #     Authorization = "Bearer {env: N8N_API_KEY}";
        #   };
        # };
        # datadog = {
        #   type = "remote";
        #   url = "https://mcp.datadoghq.eu/api/unstable/mcp-server/mcp";
        # };
      };

      # NOTE: vimcode TUI plugin is configured in programs.opencode.tui.plugin
      plugin = [ "@leohenon/opencode-vim-plugin" ];

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
    skills = ./skills;
    commands = ./commands;

    tui = {
      theme = "stylix";
    };
  };

  programs.zsh.shellAliases = {
    oc = "opencode";
  };
}
