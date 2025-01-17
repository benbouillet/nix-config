{ 
  inputs,
  config,
  username,
  host,
  pkgs,
  options,
  lib,
  ...
}: {
  programs = {
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    bat
    brave
    brightnessctl
    dig
    eza
    htop
    jq
    networkmanagerapplet
    ripgrep
    tailscale
    tree
    unrar
    unzip
    wl-clipboard
  ];
}
