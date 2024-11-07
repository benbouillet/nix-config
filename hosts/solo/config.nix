{ 
  config,
  username,
  host,
  pkgs,
  options,
  lib,
  ...
}:
let
  inherit (import ./variables.nix)
    theme
    wallpaper_file
    ;
in
{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
  ];

  # Bootloader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth.enable = true;
  };


  # Enable networking
  networking.hostName = host;
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  programs = {
    dconf.enable = true;
    mtr.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    brave
    unzip
    unrar
    ripgrep
    tree
    bat
    wl-clipboard
    tmux
    killall
    brightnessctl
    networkmanagerapplet
  ];

  fonts = {
    packages = with pkgs; [
      fira-code
      fira-code-symbols
    ];
  };

  stylix = {
    enable = true;
    image = ../../config/wallpapers/${wallpaper_file};
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
  };

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "altgr-intl";
      };
    };
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
    smartd = {
      enable = true;
      autodetect = true;
    };
    libinput.enable = true;
    fstrim.enable = true;
    gvfs.enable = true;
    openssh.enable = true;
    gnome.gnome-keyring.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  hardware.pulseaudio.enable = false;
  
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters =  [ "https://hyprland.cachix.org" ];
      trusted-public-keys =  [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than- 7d";
    };
  };

  console.keyMap = "us";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
