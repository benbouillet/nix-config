{
  pkgs,
  lib,
  username,
  ...
}:
{
  home.activation = {
    removeFirefoxBackup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      rm -f /home/ben/.mozilla/firefox/ben/search.json.mozlz4.backup
    '';
  };

  stylix.targets.firefox.profileNames = [ username ];

  programs.firefox = {
    enable = true;
    profiles.${username} = {
      name = username;
      id = 0;
      isDefault = true;
      settings = {
        "extensions.autoDisableScopes" = "0";
      };
      search = {
        default = "SearXNG";
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

          "SearXNG" = {
            urls = [ { template = "https://search.r4clette.com/search?q={searchTerms}"; } ];
            icon = "https://search.r4clette.com/static/themes/simple/img/searxng.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@sx" ];
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
        };
      };

      settings = {
        "security.webauth.webauthn" = true;
        "security.webauth.u2f" = true;
      };

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        sponsorblock
        facebook-container
        return-youtube-dislikes
        multi-account-containers
        terms-of-service-didnt-read
        duckduckgo-privacy-essentials
        augmented-steam
        privacy-badger
        adaptive-tab-bar-colour
      ];
    };
  };
}
