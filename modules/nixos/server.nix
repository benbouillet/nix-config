{
  globals,
  lib,
  inputs,
  username,
  host,
  config,
  pkgs,
  ...
}:
{
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = lib.mkForce "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = "weekly";
    };
    settings.auto-optimise-store = true;
  };

  networking = {
    hostName = host;
    usePredictableInterfaceNames = true;
    useDHCP = false; # managed by systemd.networkd
    useNetworkd = false;
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
    ];
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ]; # default deny
      # Always allow traffic from your Tailscale network
      trustedInterfaces = [ "tailscale0" ];
      # Allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];
      # Stop responding to broadcasts & noise
      logRefusedConnections = false;
      allowPing = false;
    };
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;

    networks."10-wired" = {
      matchConfig.Name = [
        "en*"
        "eth*"
      ];
      networkConfig = {
        DHCP = "ipv4";
      };
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = true; # opens TCP/22
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = "no"; # flip to "local" only if you need it
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
      ]
      ++ (lib.optional config.virtualisation.libvirtd.enable "libvirtd")
      ++ (lib.optional config.virtualisation.libvirtd.enable "kvm");
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgueapj7BN77sbhZ61B5VxL0sqrhr+H81OUDJibpeR2"
      ];
    };
  };

  programs.bash = {
    enable = true;
    shellInit = ''
      export VISUAL=vim
      set -o vi
    '';
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  # system.autoUpgrade = {
  #   enable = false;
  #   flake = "git+https://your.git/infra?ref=main";
  #   dates = "03:30";
  #   randomizedDelaySec = "30min";
  #   allowReboot = false;  # set true only if you’re comfortable
  # };

  # TAILSCALE
  services = {
    tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=${username}" ];
      extraUpFlags = [ "--operator=${username}" ];
    };
  };
  # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
  # This avoids the "iptables-compat" translation layer issues.
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "4G";
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
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
  };

  # Persistent logs
  services.journald = {
    storage = "persistent";
    extraConfig = ''
      SystemMaxUse=2G        # hard cap for all persistent journals
      SystemKeepFree=1G      # always leave at least this much free on /var
      MaxFileSec=1month      # rotate older files
      RateLimitInterval=30s
      RateLimitBurst=1000
    '';
  };

  # Fail2ban (useful only if ssh is exposed beyond Tailscale)
  services.fail2ban = {
    enable = true;
    jails.sshd.settings = {
      enabled = true;
      filter = "sshd";
      maxretry = 5;
      bantime = "1h";
      findtime = "10m";
    };
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
      "100.64.0.0/10"  # Tailscale CGNAT range
    ];
  };

  # Linux audit
  security.auditd.enable = true;
  security.audit.enable = true;

  ### SECRETS MANAGEMENT ###
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/var/lib/sops-nix/key.txt";
  };

  # Monitoring
  services.prometheus.exporters.node = {
    enable = true;
    port = globals.ports.prometheus_exporters.node;
  };
}
