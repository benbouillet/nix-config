{
  globals,
  config,
  pkgs,
  ...
}:
{
  ########################################
  # Kernel & ZFS basics
  ########################################
  boot = {
    zfs = {
      extraPools = [ "ssd" ];
    };
  };

  ########################################
  # ARC cap (adjust for your RAM)
  ########################################
  # Example: cap ARC at ~8 GiB
  boot.kernelParams = [ "zfs.zfs_arc_max=17179869184" ];

  services.prometheus.exporters.zfs = {
    enable = true;
    telemetryPath = "/metrics";
    listenAddress = "0.0.0.0";
    port = globals.ports.prometheus_exporters.zfs;
  };

  ########################################
  # Syncoid (pulling from chewie)
  ########################################
  users.groups.syncoid = { };

  users.users.syncoid = {
    isSystemUser = true;
    group = "syncoid";
    home = "/var/lib/syncoid";
    createHome = true;
    shell = pkgs.bashInteractive;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/syncoid/.ssh 0700 syncoid syncoid - -"
  ];

  security.sudo.extraRules = [
    {
      users = [ "syncoid" ];
      commands = [
        {
          command = "${pkgs.zsh}/bin/zfs";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  sops.secrets = {
    "ssh/yodaToChewieSyncoidKeyPriv" = {
      owner = "syncoid";
      group = "syncoid";
      mode = "0400";
      path = "/var/lib/syncoid/.ssh/chewie_root_ed25519";
    };
    "ssh/yodaToChewieLocal" = {
      owner = "root";
      group = "syncoid";
      mode = "0440";
    };
  };

  programs.ssh.extraConfig = ''
    Include ${config.sops.secrets."ssh/yodaToChewieLocal".path}
  '';

  ########################################
  # Options
  ########################################
  systemd.services."zfs-datasets-options-setup" = {
    description = "Setup ZFS dataset options";

    wantedBy = [ "multi-user.target" ];
    after = [
      "zfs-import.target"
      "zfs-mount.service"
    ];
    requires = [
      "zfs-import.target"
      "zfs-mount.service"
    ];

    path = [ pkgs.zfs ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
    };

    script = ''
      # SSD pool defaults
      zfs set mountpoint=none                  ssd
      zfs set compression=zstd                 ssd
      zfs set atime=off                        ssd
      zfs set xattr=sa                         ssd
      zfs set acltype=posixacl                 ssd
      zfs set aclinherit=restricted            ssd
      zfs set aclmode=discard                  ssd
      zfs set dnodesize=auto                   ssd
      zfs set recordsize=16K                   ssd

      zfs set mountpoint=none                  ssd/backups
      zfs set quota=2T                         ssd/backups

      zfs set mountpoint=none                  ssd/backups/yoda
      zfs set quota=1T                         ssd/backups/yoda
    '';
  };
}
