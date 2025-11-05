{
  lib,
  username,
  host,
  config,
  pkgs,
  ...
}:
{
  networking = {
    hostName = host;
    usePredictableInterfaceNames = true;
    useDHCP = false; # managed by systemd.networkd
    useNetworkd = false;
    nameservers = [ "8.8.8.8" "8.8.4.4"  ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];   # default deny
      allowedUDPPorts = [ ];
      # Stop responding to broadcasts & noise
      logRefusedConnections = false;
      allowPing = false;
    };
  };

  systemd.network = {
    enable = true;
    wait-online.enable = true;

    networks."10-wired" = {
      matchConfig.Name = [ "en*" "eth*" ];
      networkConfig = {
        DHCP = "ipv4";
      };
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = true;  # opens TCP/22
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = "no";              # flip to "local" only if you need it
      ClientAliveInterval = 30;
      ClientAliveCountMax = 2;
      LoginGraceTime = "30s";
      ChallengeResponseAuthentication = false;
    };
  };

  users = {
    mutableUsers = lib.mkForce false;
    users.root.hashedPassword = "!";
    users.${username} = {
      shell = lib.mkForce pkgs.bashInteractive;
      isNormalUser = true;
      hashedPassword = "!";
      extraGroups = [ "wheel" ]
        ++ (lib.optional  config.virtualisation.libvirtd.enable "libvirtd")
        ++ (lib.optional config.virtualisation.libvirtd.enable "kvm");
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

  # system.autoUpgrade = {
  #   enable = false;
  #   flake = "git+https://your.git/infra?ref=main";
  #   dates = "03:30";
  #   randomizedDelaySec = "30min";
  #   allowReboot = false;  # set true only if you’re comfortable
  # };

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
  };

  # Linux audit
  security.auditd.enable = true;
  security.audit.enable = true;
}
