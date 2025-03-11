{
  pkgs,
  username,
  ...
}:
{
  stylix.targets.firefox.profileNames = [ username ];
  programs.firefox = {
    enable = true;
    profiles.${username} = {
      name = username;
      isDefault = true;
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
            definedAliases = [ "@ho" ];
          };
    
          "NixOS Wiki" = {
            urls = [{ template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; }];
            iconUpdateURL = "https://wiki.nixos.org/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };

          "Raclette Search" = {
            urls = [{ template = "https://search.raclette.beer/search?q={searchTerms}"; }];
            iconUpdateURL = "https://search.raclette.beer/static/themes/simple/img/searxng.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@ra" ];
          };

          "GitHub" = {
            urls = [{ template = "https://github.com/search?q={searchTerms}&type=code"; }];
            definedAliases = [ "@gh" ];
          };
        };
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
