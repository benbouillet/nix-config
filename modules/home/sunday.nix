{
  pkgs,
  lib,
  username,
  auggie,
  ...
}:
let
  git_email = "ben.bouillet@sundayapp.com";
  git_name = "Ben Bouillet";
  bedrock-models = pkgs.writeShellApplication {
    name = "bedrock-models";
    runtimeInputs = [
      pkgs.awscli2
      pkgs.python3
    ];
    text = ''
      PROFILE="''${1:-ai-platform}"
      python3 - "$PROFILE" <<'EOF'
      import subprocess, json, sys

      profile = sys.argv[1]
      regions = ["eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1", "eu-north-1",
                 "us-east-1", "us-east-2", "us-west-2",
                 "ap-northeast-1", "ap-southeast-1", "ap-southeast-2", "ap-south-1"]

      # Fetch account ID once for ARN construction
      sts = subprocess.run(
          ["aws", "sts", "get-caller-identity", "--profile", profile, "--output", "json"],
          capture_output=True, text=True
      )
      account_id = json.loads(sts.stdout)["Account"] if sts.returncode == 0 else "UNKNOWN"

      def arn(region, mtype, mid):
          if mtype == "regional":
              return f"arn:aws:bedrock:{region}::foundation-model/{mid}"
          else:
              # SYSTEM_DEFINED inference profiles: eu./us./apac./global. prefixed
              prefix = mid.split(".")[0]
              if prefix == "global":
                  return f"arn:aws:bedrock:{region}:{account_id}:inference-profile/{mid}"
              else:
                  return f"arn:aws:bedrock:{region}:{account_id}:inference-profile/{mid}"

      all_models = {}
      for r in regions:
          for cmd, mtype in [
              (["aws", "bedrock", "list-foundation-models", "--region", r,
                "--profile", profile,
                "--query", "modelSummaries[].{id:modelId,name:modelName}",
                "--output", "json"], "regional"),
              (["aws", "bedrock", "list-inference-profiles", "--region", r,
                "--profile", profile,
                "--query", "inferenceProfileSummaries[].{id:inferenceProfileId,name:inferenceProfileName,type:type}",
                "--output", "json"], None),
          ]:
              result = subprocess.run(cmd, capture_output=True, text=True)
              if result.returncode != 0:
                  continue
              for m in json.loads(result.stdout):
                  key = m["id"]
                  t = mtype or m.get("type", "SYSTEM_DEFINED")
                  if key not in all_models:
                      all_models[key] = {"type": t, "name": m["name"], "regions": []}
                  if r not in all_models[key]["regions"]:
                      all_models[key]["regions"].append(r)

      # Column widths
      id_w = max(len(mid) for mid in all_models) + 2
      type_w = 14

      print(f"{'TYPE':{type_w}} {'MODEL ID':{id_w}} {'REGIONS':<40} ARN (first region)")
      print("-" * (type_w + id_w + 40 + 60))
      for mid in sorted(all_models):
          m = all_models[mid]
          first_region = m["regions"][0]
          model_arn = arn(first_region, m["type"], mid)
          regions_str = ", ".join(m["regions"])
          print(f"{m['type']:{type_w}} {mid:{id_w}} {regions_str:<40} {model_arn}")
      EOF
    '';
  };
  sundayStart = pkgs.writeShellScriptBin "sunday-start" ''
    set -e

    ${pkgs.chromium}/bin/chromium-browser \
      "https://app.v2.gather.town/app/sunday-a6ea157f-0c3c-4a79-b8d0-2c04c8a97015" &

    ${pkgs.slack}/bin/slack &

    ${pkgs.hyprland}/bin/hyprctl dispatch workspace 5
    ${pkgs.firefox}/bin/firefox -P sundayapp &
  '';
  gdk = pkgs.google-cloud-sdk.withExtraComponents (
    with pkgs.google-cloud-sdk.components;
    [
      gke-gcloud-auth-plugin
    ]
  );
in
{
  home = {
    file."dev/sundayapp/.keep" = {
      text = "";
    };

    packages =
      (with pkgs; [
        # Networking
        sshuttle
        google-cloud-sql-proxy
        awscli2
        ssm-session-manager-plugin

        # Messaging
        slack
        postman
        dbeaver-bin

        # DB
        jetbrains.datagrip
        postgresql

        # QR on bill
        balena-cli

        # AI
        claude-code
        vscode
        vscode-extensions.anthropic.claude-code
      ])
      ++ [
        gdk
        auggie
        bedrock-models
      ];

    activation = {
      removeFirefoxSundayppBackup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        rm -f /home/ben/.mozilla/firefox/sunday/search.json.mozlz4.backup
      '';
    };
  };

  xdg.desktopEntries = {
    sunday-start = {
      name = "Start Sundayapp";
      exec = "${sundayStart}/bin/sunday-start";
      terminal = false;
    };
    firefox = {
      name = "Firefox - sundayapp";
      exec = "firefox -P sundayapp";
      terminal = false;
      categories = [
        "Application"
        "Network"
        "WebBrowser"
      ];
    };
  };

  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      extensions = [
        "bgnkhhnnamicmpeenaelnjfhikgbkllg" # adguard
        "fdjamakpfbbddfjaooikfcpapjohcfmg" # dashlane
        "lejiafennghcpgmbpiodgofeklkpahoe" # Custom UserAgent String
      ];
    };
    git = {
      enable = true;
      includes = [
        {
          condition = "gitdir:/home/${username}/dev/sundayapp/";
          contents = {
            user = {
              email = git_email;
              name = git_name;
            };
            commit.gpgsign = true;
          };
        }
      ];
    };
  };

  programs.firefox = {
    profiles."sunday" = {
      name = "sundayapp";
      id = 1;
      isDefault = false;
      settings = {
        "extensions.autoDisableScopes" = "0";
      };
      search = {
        default = "Raclette Search";
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "Home Manager Options" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com/";
                params = [
                  {
                    name = "release";
                    value = "master";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@hm" ];
          };

          "NixOS Wiki" = {
            urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
            icon = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/logo/nix-snowflake-colours.svg";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };

          "Nix Docs" = {
            urls = [ { template = "https://nix.dev/manual/nix/2.24/?search={searchTerms}"; } ];
            icon = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/logo/nix-snowflake-colours.svg";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nd" ];
          };

          "Raclette Search" = {
            urls = [ { template = "https://search.r4clette.com/search?q={searchTerms}"; } ];
            definedAliases = [ "@ra" ];
          };

          "DuckduckGo" = {
            urls = [ { template = "https://duckduckgo.com/?t=h_&q={searchTerms}&ia=web"; } ];
            definedAliases = [ "@ddg" ];
          };

          "GitHub" = {
            urls = [ { template = "https://github.com/search?q={searchTerms}&type=code"; } ];
            definedAliases = [ "@gh" ];
          };

          "Wikipedia" = {
            urls = [ { template = "https://en.wikipedia.org/w/index.php?search={searchTerms}"; } ];
            definedAliases = [ "@wk" ];
          };

          "Youtube" = {
            urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
            definedAliases = [ "@yt" ];
          };

          "Github - Sunday" = {
            urls = [ { template = "https://github.com/sundayapp?q={searchTerms}&type=all&language=&sort="; } ];
            definedAliases = [ "@su" ];
          };

          "Github Code Search - Sunday" = {
            urls = [ { template = "https://github.com/search?q=org%3Asundayapp+{searchTerms}&type=code"; } ];
            definedAliases = [ "@ghsu" ];
          };
        };
      };

      bookmarks = {
        settings = [
          {
            name = "GMail Sunday";
            tags = [
              "google"
              "gmail"
              "sunday"
              "sundayapp"
            ];
            keyword = "gmail";
            url = "https://mail.google.com/mail/u/1/#inbox";
          }
          {
            name = "Gather";
            keyword = "gather";
            url = "https://app.gather.town/app/sgLPErJMsUVYXk0B/sunday";
          }
          {
            name = "Github - sundayapp";
            keyword = "github";
            url = "https://www.github.com/sundayapp/";
          }
          {
            name = "Dashlane";
            keyword = "dashlane";
            url = "https://app.dashlane.com/#/credentials";
          }
          {
            name = "Notion";
            keyword = "notion";
            url = "https://www.notion.so/sundayapp/25f55f0d4ee940a18a37b24ce060c128";
          }
          {
            name = "AWS Console";
            keyword = "aws";
            url = "https://sundayapp.awsapps.com/start/#/?tab=accounts";
          }
          {
            name = "GCP Console";
            keyword = "gcp";
            url = "https://console.cloud.google.com/";
          }
          {
            name = "Datadog Sunday Prod";
            keyword = "datadog";
            url = "https://sunday-prod.datadoghq.eu/";
          }
          {
            name = "Datadog Sunday Prod";
            keyword = "datadog";
            url = "https://sunday-alpha.datadoghq.eu/";
          }
          {
            name = "ArgoCD Prod";
            keyword = "argocd";
            url = "https://argo.int.sundayapp.xyz/";
          }
          {
            name = "ArgoCD non-Prod";
            keyword = "argocd";
            url = "https://argo.npint.sundayapp.xyz/";
          }
          {
            name = "Metabase Internal";
            keyword = "metabase-internal";
            url = "https://metabase.sundayapp.io/";
          }
          {
            name = "Metabase Public";
            keyword = "metabase-public";
            url = "https://metabase-public.sunday.cloud/";
          }
          {
            name = "POS Tooling Alpha";
            keyword = "pos-tooling-alpha";
            url = "https://pos-tooling.alpha.sundayapp.dev/";
          }
          {
            name = "POS Tooling Demo";
            keyword = "pos-tooling-demo";
            url = "https://pos-tooling.demo.sundayapp.dev/";
          }
          {
            name = "Prelude";
            keyword = "prelude";
            url = "https://app.prelude.so/";
          }
          {
            name = "Wiz";
            keyword = "wiz";
            url = "https://app.wiz.io/";
          }
        ];
        force = true;
      };

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        sponsorblock
        return-youtube-dislikes
        multi-account-containers
        terms-of-service-didnt-read
        duckduckgo-privacy-essentials
        privacy-badger
        adaptive-tab-bar-colour
        dashlane
        user-agent-string-switcher
        header-editor
        bitwarden
        vimium-c
      ];
    };
  };
  programs.nixvim = {
    plugins = {
      lsp = {
        servers = {
          kotlin_language_server.enable = true;
        };
      };
    };
  };
}
