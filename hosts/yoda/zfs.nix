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
  # Backup freshness signals (node_exporter)
  ########################################
  services.prometheus.exporters.node = {
    enabledCollectors = [
      "systemd"
      "textfile"
    ];
    extraFlags = [
      "--collector.systemd.unit-include=^syncoid-.*\\.service$"
      "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/prometheus-node-exporter-text-files 0755 root root - -"
  ];

  # Emit newest-snapshot-timestamp gauge per backup dataset so Prometheus can
  # detect silent syncoid failures (exit 0, but no fresh snapshot landed).
  systemd.services.zfs-backup-freshness-exporter = {
    description = "Export newest ZFS snapshot timestamp per backup dataset";
    path = [
      pkgs.zfs
      pkgs.coreutils
    ];
    serviceConfig.Type = "oneshot";
    script = ''
      out=/var/lib/prometheus-node-exporter-text-files/zfs_backup_freshness.prom
      tmp=$(mktemp --tmpdir="$(dirname "$out")")
      {
        echo "# HELP zfs_latest_snapshot_timestamp_seconds Unix time of newest snapshot per dataset."
        echo "# TYPE zfs_latest_snapshot_timestamp_seconds gauge"
        for ds in $(zfs list -H -o name -r ssd/backups/chewie); do
          ts=$(zfs list -H -p -t snapshot -o creation -S creation "$ds" 2>/dev/null | head -n1)
          [ -n "$ts" ] && echo "zfs_latest_snapshot_timestamp_seconds{dataset=\"$ds\"} $ts"
        done
      } > "$tmp"
      chmod 0644 "$tmp"
      mv "$tmp" "$out"
    '';
  };

  systemd.timers.zfs-backup-freshness-exporter = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "15min";
      Unit = "zfs-backup-freshness-exporter.service";
    };
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
      "infra" = {
        source = "syncoid@chewie:ssd/services/infra";
        target = "ssd/backups/chewie/services/infra";
        recursive = false;
        extraArgs = [ "--no-sync-snap" ];
      };
      "apps" = {
        source = "syncoid@chewie:ssd/services/apps";
        target = "ssd/backups/chewie/services/apps";
        recursive = false;
        extraArgs = [ "--no-sync-snap" ];
      };
      "immich" = {
        source = "syncoid@chewie:hdd/data/immich";
        target = "ssd/backups/chewie/data/immich";
        recursive = false;
        extraArgs = [ "--no-sync-snap" ];
      };
      "seafile" = {
        source = "syncoid@chewie:hdd/data/seafile";
        target = "ssd/backups/chewie/data/seafile";
        recursive = false;
        extraArgs = [ "--no-sync-snap" ];
      };
      "paperless" = {
        source = "syncoid@chewie:hdd/data/paperless";
        target = "ssd/backups/chewie/data/paperless";
        recursive = false;
        extraArgs = [ "--no-sync-snap" ];
      };
      "radicale" = {
        source = "syncoid@chewie:hdd/data/radicale";
        target = "ssd/backups/chewie/data/radicale";
        recursive = false;
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

    wantedBy = [ "zfs-mount.service" ];
    after = [ "zfs-import.target" ];
    requires = [ "zfs-import.target" ];
    before = [ "zfs-mount.service" ];

    unitConfig.DefaultDependencies = false;

    path = [ pkgs.zfs ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
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
      zfs list ssd/backups >/dev/null 2>&1 || zfs create -p ssd/backups
      zfs set mountpoint=none                  ssd/backups
      zfs set quota=2T                         ssd/backups

      # Chewie backups
      zfs list ssd/backups/chewie >/dev/null 2>&1 || zfs create -p ssd/backups/chewie
      zfs set mountpoint=none                  ssd/backups/chewie
      zfs set quota=1T                         ssd/backups/chewie

      # Chewie backup targets
      zfs list ssd/backups/chewie/db >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/db
      zfs list ssd/backups/chewie/services/infra >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/services/infra
      zfs list ssd/backups/chewie/services/apps >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/services/apps

      # Data backups
      zfs list ssd/backups/chewie/data >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/data
      zfs set mountpoint=none                  ssd/backups/chewie/data
      zfs list ssd/backups/chewie/data/seafile >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/data/seafile
      zfs list ssd/backups/chewie/data/paperless >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/data/paperless
      zfs list ssd/backups/chewie/data/immich >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/data/immich
      zfs list ssd/backups/chewie/data/radicale >/dev/null 2>&1 || zfs create -p ssd/backups/chewie/data/radicale
    '';
  };
}
