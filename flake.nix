{
  description = "Example kickstart Nix on macOS environment.";

  inputs = {
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.05";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    darwin,
    home-manager,
    homebrew-core,
    homebrew-cask,
    nix-homebrew,
    nixpkgs,
    mac-app-util,
    ...
  }: let
    darwin-system = import ./system/darwin.nix {inherit inputs username;};
    username = "ben";
  in {
    darwinConfigurations = {
      aarch64 = darwin-system "aarch64-darwin";
      x86_64 = darwin-system "x86_64-darwin";
    };
  };
}
