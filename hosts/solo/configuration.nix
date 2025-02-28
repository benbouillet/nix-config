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
    ../../modules/desktop.nix
    ../../modules/ssd.nix
    (import ../../modules/stylix.nix {inherit pkgs theme wallpaper_file;})
    ../../modules/tailscale.nix
  ];

  # DEBUG
  environment.systemPackages = with pkgs; [
    gsettings-desktop-schemas
  ];
  programs.dconf.enable = true;
  services.xserver = {
    #enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    desktopManager.gnome.enable = true; 
  };
  systemd.services.logind.enable = false;
  # END OF DEBUG

  # Enable networking
  networking.hostName = host;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  environment.etc."brave/policies/managed/default-search.json".text =
    builtins.toJSON {
      # Force Brave to enable a custom default search provider
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderName    = "DuckDuckGo";
      DefaultSearchProviderSearchURL =
        "https://duckduckgo.com/?q={searchTerms}";
      DefaultSearchProviderSuggestURL =
        "https://duckduckgo.com/ac/?q={searchTerms}";
      DefaultSearchProviderIconURL =
        "https://duckduckgo.com/favicon.ico";
  };
}
