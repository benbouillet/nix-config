{
  lib,
  config,
  pkgs,
  ...
}:
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];   # default deny
    allowedUDPPorts = [ ];
    # Stop responding to broadcasts & noise
    logRefusedConnections = false;
    allowPing = false;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;   # set true if you add TOTP/U2F 2FA
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
    users.ben = {
      shell = lib.mkForce pkgs.bashInteractive;

      # Lock the local password so console/SSH password logins are impossible
      hashedPassword = "!";                 # "!" = disabled password

      extraGroups =
        (lib.optional config.virtualisation.libvirtd.enable "libvirtd")
        ++ (lib.optional config.virtualisation.libvirtd.enable "kvm")
        ++ (lib.optional config.networking.networkmanager.enable "networkmanager");

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

  system.autoUpgrade = {
    enable = false;
    flake = "git+https://your.git/infra?ref=main";
    dates = "03:30";
    randomizedDelaySec = "30min";
    allowReboot = false;  # set true only if you’re comfortable
  };

  boot.tmp.useTmpfs = true;
  fileSystems."/tmp".options = [ "mode=1777" "nosuid" "nodev" "noexec" ];
  fileSystems."/var/tmp".options = [ "mode=1777" "nosuid" "nodev" ];

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
