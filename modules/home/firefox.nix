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
      search = {
        default = "searxng-en";
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

          "searxng-fr" = {
            urls = [ { template = "https://search.r4clette.com/search?q={searchTerms}&language=fr&safesearch=0&categories=general"; } ];
            definedAliases = [ "@fr" ];
          };

          "searxng-en" = {
            urls = [ { template = "https://search.r4clette.com/search?q={searchTerms}&language=en&safesearch=0&categories=general"; } ];
            definedAliases = [ "@en" ];
          };

          "github" = {
            urls = [ { template = "https://github.com/search?q={searchTerms}&type=code"; } ];
            definedAliases = [ "@gh" ];
          };

          "wikipedia" = {
            urls = [ { template = "https://en.wikipedia.org/w/index.php?search={searchTerms}"; } ];
            definedAliases = [ "@wk" ];
          };

          "youtube" = {
            urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
            definedAliases = [ "@yt" ];
          };
        };
      };

      settings = {
        "security.webauth.webauthn" = true;
        "security.webauth.u2f" = true;

        "extensions.autodisablescopes" = "0"; # from your first settings block

        # "keyword.enabled" = false;

        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.suggest.engines" = false;
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
