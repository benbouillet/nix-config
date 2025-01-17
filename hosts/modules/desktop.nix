{ 
  username,
  pkgs,
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
    tree
    unrar
    unzip
    wl-clipboard
  ];

  services = {
    greetd = {
      enable = true;
      vt = 3;
      settings = {
        default_session = {
          user = username;
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        };
      };
    };
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
