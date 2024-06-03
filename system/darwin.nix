{
  inputs,
  username,
}: system: let
  system-config = import ../module/configuration.nix;
  home-manager-config = import ../module/home-manager.nix;
  pkgs = import inputs.nixpkgs { system = "aarch64-darwin"; };
in
  inputs.darwin.lib.darwinSystem {
    inherit system;
    # modules: allows for reusable code

    modules = [
      {
        services.nix-daemon.enable = true;
        users.users.${username}.home = "/Users/${username}";
        time.timeZone = "Europe/Paris";
        networking.hostName = "kenobi";
        networking.localHostName = "kenobi";
        security.pam.enableSudoTouchIdAuth = true;
        fonts = {
          fontDir.enable = true; # DANGER
          fonts =
            [ (pkgs.nerdfonts.override { fonts = [ "FiraMono" ]; }) ];
        };
        system = {
          defaults = {
            finder = {
              AppleShowAllExtensions = true;
              AppleShowAllFiles = true;
              CreateDesktop = false;
              FXEnableExtensionChangeWarning = false;
              FXPreferredViewStyle = "Nlsv";
              ShowPathbar = true;
              ShowStatusBar = true;
              _FXShowPosixPathInTitle = true;
            };
            dock = {
              appswitcher-all-displays = true;
              autohide = true;
              autohide-delay = 0.5;
              minimize-to-application = true;
              orientation = "right";
              show-recents = false;
              tilesize = 24;
            };
            trackpad = {
              Clicking = true;
              Dragging = true;
              TrackpadThreeFingerDrag = true;
              TrackpadThreeFingerTapGesture = 0;
            };
          };
        };
        homebrew = {
          enable = true;
          casks = [
            "tresorit"
            "brave-browser"
            "rectangle"
            "macpass"
          ];
        };
      }
      system-config

      inputs.home-manager.darwinModules.home-manager
      {
        # add home-manager settings here
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users."${username}" = home-manager-config;
      }
      # add more nix modules here
      inputs.nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          # Install Homebrew under the default prefix
          enable = true;

          autoMigrate = true;
          # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
          enableRosetta = true;

          # User owning the Homebrew prefix
          user = "ben";

          # Optional: Declarative tap management
          taps = {
            "homebrew/homebrew-core" = inputs.homebrew-core;
            "homebrew/homebrew-cask" = inputs.homebrew-cask;
          };

          # Optional: Enable fully-declarative tap management
          #
          # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
          mutableTaps = false;
        };
      }
    ];
  }
