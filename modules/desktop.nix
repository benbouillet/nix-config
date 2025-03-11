{
  username,
  pkgs,
  ...
}:
{
  programs.dconf.enable = true;
  services.xserver = {
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    desktopManager.gnome.enable = true;
  };
  systemd.services.logind.enable = false;
  services.gnome.core-utilities.enable = false;

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
    wl-clipboard
    adwaita-icon-theme
    gsettings-desktop-schemas
  ];

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    smartd = {
      enable = true;
      autodetect = true;
    };
    fstrim.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
}
