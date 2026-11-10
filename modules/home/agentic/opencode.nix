{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  kestraSkillNames = [
    "kestra-flow-hardening"
    "kestra-flow"
    "kestra-ops"
  ];
  kestraSkills = pkgs.fetchFromGitHub {
    owner = "kestra-io";
    repo = "agent-skills";
    rev = "7d1c3443f3bc8ddb26ce4abe8ea67822033421b9";
    hash = "sha256-GdNCbu88a1RItet6D50UE7uSku5MlWng4HajM+HmIT0=";
  };
  mattPocockSkillNames = [
    "engineering/code-review"
    "engineering/codebase-design"
    "engineering/diagnosing-bugs"
    "engineering/domain-modeling"
    "engineering/grill-with-docs"
    "engineering/implement-spec"
    "engineering/implement"
    "engineering/improve-codebase-architecture"
    "engineering/pr"
    "engineering/prototype"
    "engineering/research"
    "engineering/retro"
    "engineering/to-spec"
    "engineering/to-tickets"
    "engineering/triage"
    "engineering/wayfinder"
    "productivity/grill-me"
    "productivity/grilling"
    "productivity/handoff"
    "productivity/teach"
    "productivity/to-questionnaire"
    "productivity/wait-what"
    "productivity/writing-for-agents"
  ];
  mattPocockSkills = inputs.mattpocock-skills;
  localSkills = lib.mapAttrs (name: _: ./skills/${name}) (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills)
  );
  skills =
    localSkills
    // lib.genAttrs kestraSkillNames (name: "${kestraSkills}/skills/${name}")
    // lib.genAttrs mattPocockSkillNames (name: "${mattPocockSkills}/skills/${name}");
in
{
  home.activation.removeOpencodeBackup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f /home/ben/.config/opencode/opencode.json.backup
  '';

  sops.secrets."ai/openrouter_api_key" = { };
  sops.secrets."ai/sunday_litellm_api_key" = { };
  sops.secrets."ai/sunday_n8n_api_key" = { };
  sops.secrets."ai/sunday_linear_api_key" = { };
  sops.secrets."litellm/opencode-api-key" = { };
  sops.secrets."sunday/kestra_tailnet_mcp_url" = { };

  sops.templates."opencode/auth.json" = {
    mode = "0400";
    content = ''
      {
        "litellm-r4clette": {
          "type": "api",
          "key": "${config.sops.placeholder."litellm/opencode-api-key"}"
        }
      }
    '';
  };

  home.file.".local/share/opencode/auth.json" = {
    source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."opencode/auth.json".path;
  };

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
    pkgs.playwright-mcp
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    mutableSettings = true;

    settings = {
      autoshare = false;
      autoupdate = false;

      default_agent = "zeus";
      model = "litellm/deepseek.deepseek-v4-pro";
      small_model = "litellm/deepseek.deepseek-v4-flash";

      skills = { };
      permission = { };

      provider = {
        "litellm-r4clette" = {
          npm = "@ai-sdk/openai-compatible";
          name = "llama-cpp (chewie)";
          options = {
            baseURL = "https://litellm.r4clette.com/v1";
          };
          models = {
            "qwen3.8:27b" = {
              name = "Qwen 3.8 27b (chewie)";
              limit = {
                context = 131072;
                output = 32768;
              };
            };
            "gemma4-26b-instruct" = {
              name = "Gemma 4 26B-A4B Instruct (local)";
              limit = {
                context = 131072;
                output = 32768;
              };
            };
          };
        };
      };
      mcp = {
        nixos = {
          enabled = false;
          type = "local";
          command = [ "mcp-nixos" ];
        };
        degoog = {
          enabled = false;
          type = "remote";
          url = "https://search.r4clette.com/mcp";
        };
        kestra = {
          enabled = false;
          type = "remote";
          url = "https://kestra.r4clette.com/mcp";
        };
        servers.playwright = {
          type = "local";
          command = [ (lib.getExe pkgs.playwright-mcp) ];
        };
      };

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
    skills = skills;
    commands = ./commands;

    validateFiles.cli = true;

    cli = {
      theme.name = "stylix";
      plugins = [
        {
          package = "@leohenon/opencode-vim-plugin@0.2.0-beta.2";
          options = {
            enabled = true;
            toggle_key = "ctrl+shift+v";
            indicator = true;
          };
        }
      ];
      tabs = {
        mode = "off";
        scope = "global";
        layout = "horizontal";
        indicators = "status";
      };
      session = {
        sidebar = "hide";
        thinking = "hide";
        scrollbar = true;
        verbosity = "medium";
      };
    };
  };

  programs.zsh.shellAliases = {
    oc = "opencode";
  };
}
