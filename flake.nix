{
  description = "My Thinkpad T480 configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware?ref=master";
  };

  outputs = inputs@{ self, nixpkgs, ... }: 
  let
    system = "aarch64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations.nixos = {
      modules = [
        ./nixos/configuration.nix
	./nixos/hardware-configuration.nix
	inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
      ];
    };
  };
}
