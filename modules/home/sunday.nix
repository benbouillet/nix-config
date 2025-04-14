{
  pkgs,
  username,
  ...
}:
let
  git_email = "ben.bouillet@sundayapp.com";
  git_name = "Ben Bouillet";
in {
  home = {
    file."dev/sundayapp/.keep" = {
      text = "";
    };

    packages = with pkgs; [
      # Networking
      sshuttle

      # Cloud
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      awscli2

      # Messaging
      slack
      postman
      dbeaver-bin
    ];
  };

  xdg.desktopEntries = {
    firefox = {
      name = "Firefox - sundayapp";
      exec = "firefox -P sundayapp";
      terminal = false;
      categories = [ "Application" "Network" "WebBrowser" ];
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
      includes =  [
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
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "channel"; value = "unstable"; }
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "Nix Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "channel"; value = "unstable"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "Home Manager Options" = {
            urls = [{
              template = "https://home-manager-options.extranix.com/";
              params = [
                { name = "release"; value = "master"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@hm" ];
          };

          "NixOS Wiki" = {
            urls = [{ template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; }];
            icon = "https://wiki.nixos.org/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };

          "Raclette Search" = {
            urls = [{ template = "https://search.raclette.beer/search?q={searchTerms}"; }];
            icon = "https://search.raclette.beer/static/themes/simple/img/searxng.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@ra" ];
          };

          "GitHub" = {
            urls = [{ template = "https://github.com/search?q={searchTerms}&type=code"; }];
            definedAliases = [ "@gh" ];
          };

          "Wikipedia" = {
            urls = [{ template = "https://en.wikipedia.org/w/index.php?search={searchTerms}"; }];
            definedAliases = [ "@wk" ];
          };

          "Youtube" = {
            urls = [{ template = "https://www.youtube.com/results?search_query={searchTerms}"; }];
            definedAliases = [ "@yt" ];
          };

          "Github - Sunday" = {
            urls = [{ template = "https://github.com/sundayapp?q={searchTerms}&type=all&language=&sort="; }];
            definedAliases = [ "@su" ];
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
      ];
    };
  };
}
