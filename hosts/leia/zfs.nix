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
  # Cap ARC at ~16 GiB
  boot.kernelParams = [ "zfs.zfs_arc_max=17179869184" ];

  services.prometheus.exporters.zfs = {
    enable = true;
    telemetryPath = "/metrics";
    listenAddress = "0.0.0.0";
    port = globals.ports.prometheus_exporters.zfs;
  };

  ########################################
  # Snapshots
  ########################################
  # services.sanoid.datasets = {
  #   "ssd/backups" = {
  #     use_template = [ "backup" ];
  #     recursive = true;
  #     process_children_only = true;
  #   };
  # };

  ########################################
  # Options
  ########################################
  # systemd.services."zfs-datasets-options-setup" = {
  #   description = "Setup ZFS dataset options";
  #
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "zfs-import.target" ];
  #   requires = [ "zfs-import.target" ];
  #
  #   path = [ pkgs.zfs ];
  #
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     User = "root";
  #     Group = "root";
  #   };
  #
  #   script = ''
  #     # SSD pool defaults
  #     zfs set mountpoint=none                  ssd
  #     zfs set compression=zstd                 ssd
  #     zfs set atime=off                        ssd
  #     zfs set xattr=sa                         ssd
  #     zfs set acltype=posixacl                 ssd
  #     zfs set aclinherit=restricted            ssd
  #     zfs set aclmode=discard                  ssd
  #     zfs set dnodesize=auto                   ssd
  #     zfs set recordsize=16K                   ssd
  #
  #     # Backups defaults
  #     zfs list ssd/backups >/dev/null 2>&1 || zfs create -p ssd/backups
  #     zfs set mountpoint=none                  ssd/backups
  #     zfs set quota=2T                         ssd/backups
  #
  #     # Chewie backups
  #     zfs list ssd/backups/chewie >/dev/null 2>&1 || zfs create -p ssd/backups/chewie
  #     zfs set mountpoint=none                  ssd/backups/chewie
  #     zfs set quota=1T                         ssd/backups/chewie
  #
  #     # Chewie backup targets
  #     zfs list ssd/backups/chewie/db >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/db
  #     zfs list ssd/backups/chewie/services/infra >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/services/infra
  #     zfs list ssd/backups/chewie/services/apps >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/services/apps
  #
  #     # Data backups
  #     zfs list ssd/backups/chewie/data >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/data
  #     zfs set mountpoint=none                  ssd/backups/chewie/data
  #     zfs list ssd/backups/chewie/data/seafile >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/data/seafile
  #     zfs list ssd/backups/chewie/data/paperless >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/data/paperless
  #     zfs list ssd/backups/chewie/data/immich >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/data/immich
  #     zfs list ssd/backups/chewie/data/radicale >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/data/radicale
  #   '';
  # };
}
