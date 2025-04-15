{
  description = "My Thinkpad T480 configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware?ref=master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### MAC ###
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";

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
  };

  outputs = {
    nixpkgs,
    home-manager,
    darwin,
    mac-app-util,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    username = "ben";
  in
  {
    nixosConfigurations = {
      "obiwan" = let
          host = "obiwan";
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit system;
            inherit host;
            inherit username;
          };
          modules = [
            ./hosts/${host}/configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager = {
                extraSpecialArgs = {
                  inherit username;
                  inherit inputs;
                  inherit host;
                };
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.${username} = import ./hosts/${host}/home.nix;
              };
            }
          ];
        };
      "solo" = let
          host = "solo";
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit system;
            inherit host;
            inherit username;
          };
          modules = [
            ./hosts/${host}/configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager = {
                extraSpecialArgs = {
                  inherit username;
                  inherit inputs;
                  inherit host;
                };
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.${username} = import ./hosts/${host}/home.nix;
              };
            }
          ];
        };
      "windu" = let
          host = "windu";
        in
        darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
            inherit system;
            inherit host;
            inherit username;
          };
        modules = [
          ./hosts/${host}/system.nix
          ./hosts/${host}/apps.nix
          ./hosts/${host}/host-users.nix
          ./hosts/${host}/nix-core.nix

          mac-app-util.darwinModules.default

          # home manager
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit username host;
            };
            home-manager.users.${username} = import ./hosts/${host}/home.nix;
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
            ];
          }

          nix-homebrew.darwinModules.nix-homebrew {
            nix-homebrew = {
              enable = true;

              enableRosetta = true;

              user = username;

              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
              mutableTaps = false;
              autoMigrate = true;
            };
          }
        ];
        };
    };
  };
}
