{
  globals,
  config,
  pkgs,
  lib,
  ...
}:
let
  # ZFS structural dataset layout — applied by zfs-datasets-options-setup
  # Order matters: parents must come before children
  zfsDatasets = [
    {
      ds = "ssd";
      props = {
        mountpoint = "none";
        compression = "zstd";
        atime = "off";
        xattr = "sa";
        acltype = "posixacl";
        aclinherit = "restricted";
        aclmode = "discard";
        dnodesize = "auto";
        recordsize = "16K";
      };
    }
    {
      ds = "ssd/backups";
      props = {
        mountpoint = "none";
        quota = "2T";
      };
      create = true;
    }
    {
      ds = "ssd/backups/chewie";
      props = {
        mountpoint = "none";
        quota = "1T";
      };
      create = true;
    }
    {
      ds = "ssd/backups/chewie/data";
      props = {
        mountpoint = "none";
      };
      create = true;
    }
  ];

  # Backups pulled from chewie via syncoid
  chewieBackups = [
    {
      source = "syncoid@chewie:ssd/db";
      target = "ssd/backups/chewie/db";
      recursive = true;
    }
    {
      source = "syncoid@chewie:ssd/services/infra";
      target = "ssd/backups/chewie/services/infra";
      recursive = false;
    }
    {
      source = "syncoid@chewie:ssd/services/apps";
      target = "ssd/backups/chewie/services/apps";
      recursive = false;
    }
    {
      source = "syncoid@chewie:hdd/data/immich";
      target = "ssd/backups/chewie/data/immich";
      recursive = false;
    }
    {
      source = "syncoid@chewie:hdd/data/seafile";
      target = "ssd/backups/chewie/data/seafile";
      recursive = false;
    }
    {
      source = "syncoid@chewie:hdd/data/paperless";
      target = "ssd/backups/chewie/data/paperless";
      recursive = false;
    }
    {
      source = "syncoid@chewie:hdd/data/radicale";
      target = "ssd/backups/chewie/data/radicale";
      recursive = false;
    }
  ];

  mkDatasetScript =
    {
      ds,
      props,
      create ? false,
      ...
    }:
    let
      createLine = lib.optionalString create "zfs create -p ${ds} 2>/dev/null || true";
      propLines = lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "zfs set ${k}=${v} ${ds}") props);
    in
    lib.concatStringsSep "\n" (
      lib.filter (s: s != "") [
        createLine
        propLines
      ]
    );
in
{
  ########################################
  # Kernel & ZFS basics
  ########################################
  boot = {
    zfs = {
      extraPools = [ "ssd" ];
    };
  };

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
    commands = builtins.listToAttrs (
      map (e: {
        name = e.source;
        value = {
          inherit (e) source target recursive;
          extraArgs = [ "--no-sync-snap" ];
        };
      }) chewieBackups
    );
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
      # Structural dataset properties & layout
      ${lib.concatMapStringsSep "\n\n" mkDatasetScript zfsDatasets}

      # Syncoid target datasets
      ${lib.concatMapStringsSep "\n" (e: "zfs create -p ${e.target} 2>/dev/null || true") chewieBackups}
    '';
  };
}
