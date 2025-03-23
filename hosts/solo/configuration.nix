{
  inputs,
  config,
  username,
  host,
  pkgs,
  options,
  lib,
  ...
}: let
  inherit (import ./variables.nix)
    theme
    wallpaper_file
    ;
in
{
  imports = [
    inputs.hardware.nixosModules.lenovo-thinkpad-t480

    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/wireless.nix
    ../../modules/desktop.nix
    ../../modules/hyprland.nix
    ../../modules/ssd.nix
    ../../modules/tailscale.nix
    ../../modules/sops.nix
    (import ../../modules/stylix.nix {inherit pkgs theme username wallpaper_file;})
  ];

  # Enable networking
  networking.hostName = host;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
