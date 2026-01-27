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

    stylix.url = "github:danth/stylix";

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
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixos-generators,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "ben";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        "obiwan" =
          let
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
              home-manager.nixosModules.home-manager
              {
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
        "chewie" =
          let
            host = "chewie";
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              inherit system;
              inherit host;
              inherit username;
            };
            modules = [
              inputs.disko.nixosModules.disko
              inputs.sops-nix.nixosModules.sops
              inputs.impermanence.nixosModules.impermanence
              ./hosts/${host}/configuration.nix
            ];
          };
      };
      packages.${system}.usbboot = nixos-generators.nixosGenerate {
        system = system;
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

      devShells.${system} = {
        default =
          let
            nixdeploy = pkgs.writeShellApplication {
              name = "nixdeploy";
              text = ''
                nixos-rebuild switch --flake ".#$1" \
                  --target-host "$1" \
                  --build-host "$1" \
                  --sudo \
                  --use-substitutes
              '';
            };
          in
          pkgs.mkShell {
            name = "flake-dev";
            packages = with pkgs; [
              nixfmt-rfc-style
              nil
              deadnix
              statix
              alejandra
              nixdeploy
            ];
            shellHook = ''
              echo "Dev shell ready. Useful commands:"
              echo "  nix fmt"
              echo "  nil"
            '';
          };
      };

      # Optional: make `nix fmt` work
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
