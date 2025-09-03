{
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
    eza
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
