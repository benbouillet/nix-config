{
  lib,
  pkgs,
  ...
}:
{
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
    dig
    tmux
    eza
    file-roller
    htop
    jq
    ripgrep
    tree
    unzip
    dive
    jless
    tldr
    wtype
    wl-clipboard
    brightnessctl
    networkmanagerapplet
    usbutils
  ];

  networking = {
    networkmanager = {
      enable = true;
    };
    useDHCP = lib.mkDefault true;
  };


  boot = {
    plymouth.enable = true;
  };

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "FiraCode" ];
        sansSerif = [ "Roboto" ];
        serif = [ "Roboto Serif" ];
      };
    };
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      roboto
      roboto-serif
      noto-fonts-monochrome-emoji
    ];
  };

  environment.pathsToLink = [
    "/share/zsh"
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  programs.gnupg.agent = {
    enable = true;
    settings = {
        default-cache-ttl = 2160000;
    };
  };

  ### AUDIO ###
  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    # Thunar media & trash management
    gvfs.enable = true;
    tumbler.enable = true;
  };

  ### BLUETOOTH ###
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
}
