{
  description = "Home Configurations";

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

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    sunday-augment = {
      url = "git+ssh://git@github.com/sundayapp/augment-tools";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixos-generators,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      username = "ben";

      # obiwan-only packages (x86_64)
      pkgs = pkgsFor "x86_64-linux";
      auggie = import ./packages/auggie/package.nix { inherit pkgs; };
      opencode-augment-auth = import ./packages/opencode-augment-auth/package.nix { inherit pkgs; };

      mkHost =
        {
          host,
          extraModules ? [ ],
          extraSpecialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs host username;
          }
          // extraSpecialArgs;
          modules = [ ./hosts/${host}/configuration.nix ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        "obiwan" = mkHost {
          host = "obiwan";
          extraSpecialArgs = { inherit auggie; };
          extraModules = [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = {
                  inherit
                    username
                    inputs
                    auggie
                    opencode-augment-auth
                    ;
                  host = "obiwan";
                };
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.${username} = import ./hosts/obiwan/home.nix;
              };
            }
          ];
        };
        "chewie" = mkHost {
          host = "chewie";
          extraModules = [
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            inputs.impermanence.nixosModules.impermanence
          ];
        };
        "yoda" = mkHost {
          host = "yoda";
          extraModules = [
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            inputs.impermanence.nixosModules.impermanence
          ];
        };
        "leia" = mkHost {
          host = "leia";
          extraModules = [
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            inputs.impermanence.nixosModules.impermanence
          ];
        };
        rpiSdImage = nixpkgs.lib.nixosSystem {
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            {
              nixpkgs.config.allowUnsupportedSystem = true;
              nixpkgs.hostPlatform.system = "aarch64-linux";
              nixpkgs.buildPlatform.system = "x86_64-linux";
              services.openssh = {
                enable = true;
                settings = {
                  PasswordAuthentication = false;
                  KbdInteractiveAuthentication = false;
                  PermitRootLogin = "prohibit-password";
                };
              };
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgueapj7BN77sbhZ61B5VxL0sqrhr+H81OUDJibpeR2"
              ];
            }
          ];
        };
      };
      packages = forAllSystems (system: {
        usbboot = nixos-generators.nixosGenerate {
          inherit system;
          format = "install-iso";
          modules = [
            {
              nix = {
                settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];
              };
              programs.git.enable = true;

              services.openssh = {
                enable = true;
                settings = {
                  PasswordAuthentication = false;
                  KbdInteractiveAuthentication = false;
                  PermitRootLogin = "prohibit-password";
                };
              };
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgueapj7BN77sbhZ61B5VxL0sqrhr+H81OUDJibpeR2"
              ];
              networking.networkmanager.enable = true;
            }
          ];
        };
      });

      devShells = forAllSystems (
        system:
        let
          spkgs = pkgsFor system;
          nixdeploy = spkgs.writeShellApplication {
            name = "nixdeploy";
            text = ''
              nixos-rebuild switch --flake ".#$1" \
                --target-host "$1" \
                --build-host "$1" \
                --sudo \
                --use-substitutes
            '';
          };
          scram-sha-256-build = spkgs.buildGoModule {
            name = "scram-sha-256";
            src = spkgs.fetchFromGitHub {
              owner = "supercaracal";
              repo = "scram-sha-256";
              rev = "v1.1.0";
              hash = "sha256-gl0q3q/24CALYuK9v23c9PZZPdmdSzkR6fAfLeLrgBA=";
            };
            vendorHash = "sha256-L7nK+w4CB2H3b6vL0ZoFfaRMgCmpqzQo8ThMM60C76I=";
          };
          scram-sha-256 = spkgs.writeShellApplication {
            name = "scram-sha-256";
            text = ''
              ${scram-sha-256-build}/bin/term
            '';
          };
          rpi-sdimage = spkgs.writeShellApplication {
            name = "rpi-sdimage";
            text = ''
              nix build .#nixosConfigurations.rpiSdImage.config.system.build.sdImage
            '';
          };
        in
        {
          default = spkgs.mkShell {
            name = "flake-dev";
            packages = with spkgs; [
              nixfmt-rfc-style
              nil
              deadnix
              statix
              nixdeploy
              scram-sha-256
              rpi-sdimage
            ];
            shellHook = ''
              echo "Dev shell ready. Useful commands:"
              echo "  nix fmt"
              echo "  nil"
            '';
          };
        }
      );

      formatter = forAllSystems (system: (pkgsFor system).nixfmt-rfc-style);
    };
}
