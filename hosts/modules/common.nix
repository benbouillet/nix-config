{
  pkgs,
  username,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;
  };

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
      options = "--delete-older-than 7d";
    };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth.enable = true;
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  console.keyMap = "us";

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
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
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

  services = {
    libinput.enable = true;
    openssh.enable = true;
    smartd = {
      enable = true;
      autodetect = true;
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    killall
    tmux
    vim
    wget
  ];

  users = {
    mutableUsers = true;
    users."${username}" = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
  };
}
