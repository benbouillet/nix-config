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
  };

  outputs = {
    nixpkgs,
    home-manager,
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
    };
  };
}
