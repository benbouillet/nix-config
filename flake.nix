{
  description = "My Thinkpad T480 configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware?ref=master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    stylix.url = "github:danth/stylix";
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixos-hardware,
    stylix,
    nixvim,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    host = "solo";
    username = "ben";
  in
  {
    nixosConfigurations = {
      "${host}" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit system;
          inherit host;
          inherit username;
        };
        modules = [
          ./hosts/${host}/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t480
          home-manager.nixosModules.home-manager {
            home-manager.extraSpecialArgs = {
              inherit username;
              inherit inputs;
              inherit host;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./hosts/${host}/home.nix;
            home-manager.sharedModules = [
              nixvim.homeManagerModules.nixvim
            ];
          }
	  stylix.nixosModules.stylix
        ];
      };
    };
  };
}
