{
  lib,
  username,
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  programs = {
    nix-ld.enable = true;
    thunar = {
      enable = true;
      plugins = [
        pkgs.thunar-archive-plugin
        pkgs.thunar-volman
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
    jq
    yq-go
    tldr
    wtype
    wl-clipboard
    brightnessctl
    networkmanagerapplet
    usbutils
    sops
    age
    nvd
  ];

  networking = {
    networkmanager = {
      enable = true;
      # Use systemd-resolved as the DNS backend so NM and Tailscale cooperate
      # via D-Bus instead of racing to overwrite /etc/resolv.conf
      dns = "systemd-resolved";
    };
    useDHCP = false;
    extraHosts = "172.16.32.45 litellm-admin.int.sundayapp.xyz";
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false"; # Tailscale MagicDNS doesn't support DNSSEC
      Domains = [ "~." ];
      FallbackDNS = "8.8.8.8 8.8.4.4";
    };
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;
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
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Thunar media & trash management
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  ### BLUETOOTH ###
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  ### SECRETS MANAGEMENT ###
  imports = [ inputs.sops-nix.nixosModules.sops ];
  sops = {
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
  };

  ### KEYRING ###
  services.gnome = {
    gnome-keyring.enable = true;
    gcr-ssh-agent.enable = false;
  };
  security.pam.services = {
    login.enableGnomeKeyring = true;
    greetd.enableGnomeKeyring = true;
    hyprland.enableGnomeKeyring = true;
  };

  # Tailscale
  services = {
    tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=${username}" ];
      extraUpFlags = [ "--operator=${username}" ];
    };
  };
}
