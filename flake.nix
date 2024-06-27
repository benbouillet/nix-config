{
  description = "Nix for macOS configuration";

  inputs = {
    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    mac-app-util.url = "github:hraban/mac-app-util";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-services = {
      url = "github:homebrew/homebrew-services";
      flake = false;
    };
  };

###################################################
################### OUTPUTS #######################
###################################################
    outputs = inputs @ { self, nixpkgs, darwin, home-manager, mac-app-util, nixvim, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, homebrew-services,... }: let
    username = "ben";
    useremail = "15980664+benbouillet@users.noreply.github.com";
    system = "aarch64-darwin"; # aarch64-darwin or x86_64-darwin

    getHostConfig = hostname: let
      hostConfigPath = ./hosts/${hostname}.nix;
    in
      if builtins.pathExists hostConfigPath
      then import hostConfigPath
      else { pkgs = []; casks = []; };

    hostnames = [ "kenobi" "windu" ];
  in {
    darwinConfigurations = builtins.listToAttrs (map (hostname: {
      name = hostname;
      value = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = inputs // {
          inherit username useremail hostname;
          hostConfig = getHostConfig hostname;
        };
        modules = [
          ./modules/nix-core.nix
          ./modules/system.nix
          ./modules/apps.nix
          ./modules/host-users.nix

          mac-app-util.darwinModules.default

          # home manager
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit username useremail hostname;
              hostConfig = getHostConfig hostname;
            };
            home-manager.users.${username} = import ./home;
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
              nixvim.homeManagerModules.nixvim
            ];
          }

          nix-homebrew.darwinModules.nix-homebrew {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;
  
              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;
  
              # User owning the Homebrew prefix
              user = username;
  
              # Optional: Declarative tap management
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
                "homebrew/homebrew-services" = homebrew-services;
              };
  
              # Optional: Enable fully-declarative tap management
              #
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
              autoMigrate = true;
            };
          }
        ];
      };
    }) hostnames);

    # nix code formatter
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
