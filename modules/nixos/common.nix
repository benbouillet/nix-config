{
  inputs,
  lib,
  pkgs,
  username,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlays.default
    ];
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      download-buffer-size = 512 * 1024 * 1024;

      substituters =  [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys =  [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
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

  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Paris";

  console.keyMap = "us";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

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
    killall
    vim
    wget
  ];

  users = {
    mutableUsers = lib.mkDefault true;
    users."${username}" = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
      shell = lib.mkDefault pkgs.zsh;
      ignoreShellProgramCheck = lib.mkDefault true;
    };
  };
}
