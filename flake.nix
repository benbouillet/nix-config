{
  description = "My Thinkpad T480 configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixos-hardware.url = "github:nixos/nixos-hardware?ref=master";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = inputs@{ self, nixpkgs, ... }: 
  let
    user = "ben";
    fullname = "Ben Bouillet";
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
      };
    };

  in
  {
    nixosConfigurations = {
      solo = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs user fullname system; };

        modules = [
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
          ./nixos/configuration.nix
        ];
      };
    };
  };
}
