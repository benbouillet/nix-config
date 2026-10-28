{
  inputs,
  username,
  host,
  pkgs,
  lib,
  config,
  ...
}:
{
  _module.args.globals = inputs.nix-private.globals.shared;

  sops.defaultSopsFile = "${inputs.nix-private}/secrets/kylo.yaml";

  imports = [
    ./hardware-configuration.nix
    ./impermanence.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/nebula-client.nix
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    libcamera
    (rpi.rpicam-apps.override {
      withLibavEncoder = false;
      withDrmPreview = false;
      withEglPreview = false;
      withQtPreview = false;
      withOpenCVPostProc = false;
      withIMX500 = false;
    })
    v4l-utils
  ];

  services.smartd.enable = lib.mkForce false;

  services.udev.extraRules = ''
    SUBSYSTEM=="dma_heap", KERNEL=="default_cma_region", SYMLINK+="dma_heap/linux,cma"
  '';

  hardware.raspberry-pi.config.all.dt-overlays.vc4-kms-v3d.params.cma-256.enable = true;

  nix = {
    gc = {
      automatic = lib.mkForce true;
      dates = lib.mkForce "weekly";
      options = lib.mkForce "--delete-older-than 14d";
    };
    settings = {
      auto-optimise-store = lib.mkForce false;
      extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
      extra-trusted-public-keys = [
        "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      ];
      trusted-users = lib.mkAfter [ "ben" ];
      min-free = lib.mkForce (1 * 1024 * 1024 * 1024);
      max-free = lib.mkForce (5 * 1024 * 1024 * 1024);
    };
  };

  networking = {
    hostName = host;
    usePredictableInterfaceNames = true;
    useDHCP = false;
    useNetworkd = false;
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
    ];
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [
        4242
        config.services.tailscale.port
      ];
      logRefusedConnections = false;
      allowPing = false;
    };
  };

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--operator=${username}" ];
    extraUpFlags = [ "--operator=${username}" ];
  };

  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  systemd.network = {
    enable = true;
    wait-online.enable = false;
    networks."10-wired" = {
      matchConfig.Name = [
        "en*"
        "eth*"
      ];
      networkConfig.DHCP = "yes";
    };
  };

  services.openssh = {
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = "no";
      ClientAliveInterval = 30;
      ClientAliveCountMax = 2;
      LoginGraceTime = "30s";
      ChallengeResponseAuthentication = false;
      AuthorizedKeysFile = ".ssh/authorized_keys /etc/ssh/authorized_keys.d/%u";
    };
  };

  users = {
    mutableUsers = lib.mkForce false;
    users.root.hashedPassword = "!";
    users.${username} = {
      shell = lib.mkForce pkgs.bashInteractive;
      isNormalUser = true;
      hashedPassword = "!";
      extraGroups = [
        "wheel"
        "video"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgueapj7BN77sbhZ61B5VxL0sqrhr+H81OUDJibpeR2"
      ];
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  programs.bash = {
    enable = true;
    shellInit = ''
      export VISUAL=vim
      set -o vi
    '';
  };

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.forwarding" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
  };

  services.journald = {
    storage = "volatile";
    extraConfig = "RuntimeMaxUse=128M";
  };

  swapDevices = [
    {
      device = "/persist/nix-build.swap";
      size = 4096;
    }
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.useSystemdActivation = true;

  systemd.services."nebula@tarkin" = {
    requires = [ "sops-install-secrets.service" ];
    after = [ "sops-install-secrets.service" ];
  };

  system.stateVersion = "25.05";
}
