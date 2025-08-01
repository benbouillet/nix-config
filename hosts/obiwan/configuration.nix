{
  inputs,
  username,
  host,
  pkgs,
  config,
  ...
}: let
  inherit (import ./variables.nix)
    theme
    wallpaper_file
    ;
in
{
  imports = [
    inputs.hardware.nixosModules.framework-13-7040-amd

    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/wireless.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/hyprland.nix
    ../../modules/nixos/ssd.nix
    ../../modules/nixos/tailscale.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/vpn.nix
    (import ../../modules/nixos/stylix.nix {inherit inputs pkgs theme username wallpaper_file;})
  ];

  sops.secrets."github/pat" = { };
  nix.extraOptions = "!include ${config.sops.secrets."github/pat".path}";

  # Enable Firmware update
  # services.fwupd.enable = true;

  # Enable networking
  networking.hostName = host;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
