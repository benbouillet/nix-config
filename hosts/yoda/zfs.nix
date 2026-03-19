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
  sops.secrets = {
    "ssh/yodaToChewieSyncoidKeyPriv" = {
      owner = "syncoid";
      group = "syncoid";
      mode = "0400";
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

  services.syncoid = {
    enable = true;
    sshKey = config.sops.secrets."ssh/yodaToChewieSyncoidKeyPriv".path;
    interval = "*-*-* 04:00:00";
    commands = {
      "databases" = {
        source = "syncoid@chewie:ssd/db";
        target = "ssd/backups/chewie/db";
        recursive = true;
        extraArgs = [ "--no-sync-snap" ];
      };
    };
  };

  ########################################
  # Snapshots
  ########################################
  services.sanoid.datasets = {
    "ssd/backups" = {
      use_template = [ "backup" ];
      recursive = true;
      process_children_only = true;
    };
  };

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

      # Backups defaults
      zfs create -p                            ssd/backups 2>/dev/null || true
      zfs set mountpoint=none                  ssd/backups
      zfs set quota=2T                         ssd/backups

      # Chewie backups
      zfs create -p                            ssd/backups/chewie 2>/dev/null || true
      zfs set mountpoint=none                  ssd/backups/chewie
      zfs set quota=1T                         ssd/backups/chewie

      # Chewie backup targets
      zfs create -p                            ssd/backups/chewie/db 2>/dev/null || true
    '';
  };
}
