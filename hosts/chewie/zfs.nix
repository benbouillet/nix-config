{
  globals,
  pkgs,
  ...
}:
let
  yodaToChewiePublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBULf9dIT77X0zgCIIvFN/CORkEckj47Fn1mTc3AfFtY root@yoda";
  rsyncNet = globals.rsyncNet;
in
{
  ########################################
  # Kernel & ZFS basics
  ########################################
  boot = {
    zfs = {
      extraPools = [
        "hdd"
        "ssd"
      ];
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
  # Snapshots
  ########################################
  services.sanoid.datasets = {
    "hdd/data" = {
      use_template = [ "cold" ];
      recursive = true;
    };
    "hdd/data/media" = {
      use_template = [ "nosnapshot" ];
    };
    "ssd/db" = {
      use_template = [ "highchurn" ];
      recursive = true;
    };
    "ssd/services" = {
      use_template = [ "standard" ];
      recursive = true;
    };
  };

  ########################################
  # Syncoid pulled from yoda
  ########################################
  users.users.syncoid = {
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      yodaToChewiePublicKey
    ];
  };

  sops.secrets."rsync-net/ssh-key" = {
    owner = "syncoid";
    mode = "0400";
  };

  sops.secrets."rsync-net/ssh-config" = {
    owner = "syncoid";
    mode = "0400";
  };

  sops.secrets."rsync-net/known-hosts" = {
    owner = "syncoid";
    mode = "0444";
  };

  programs.ssh.extraConfig = "Include /run/secrets/rsync-net/ssh-config";

  systemd.services."rsync-net-datasets-setup" = {
    description = "Ensure rsync.net ZFS datasets exist";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.openssh ];
    serviceConfig = {
      Type = "oneshot";
      User = "syncoid";
    };
    script =
      let
        datasets = [ "${rsyncNet.pool}/${rsyncNet.namespace}" ];
      in
      builtins.concatStringsSep "\n" (
        map (ds: "ssh rsync-net \"zfs list ${ds} 2>/dev/null || zfs create -p ${ds}\"") datasets
      );
  };

  services.syncoid = {
    enable = true;
    localTargetAllow = [ ];
    commonArgs = [
      "--no-sync-snap"
      "--compress=zstd-fast"
      "--no-resume"
      "--quiet"
    ];
    commands = {
      "offsite-db" = {
        source = "ssd/db";
        target = "rsync-net:${rsyncNet.pool}/${rsyncNet.namespace}/db";
        extraArgs = [ "--recursive" ];
      };
    };
  };

  systemd.services."syncoid-offsite-db" = {
    after = [ "rsync-net-datasets-setup.service" ];
    requires = [ "rsync-net-datasets-setup.service" ];
  };

  ########################################
  # Sanoid remote pruning (rsync.net)
  ########################################
  services.sanoid.datasets = {
    "rsync-net:${rsyncNet.pool}/${rsyncNet.namespace}/db/postgres" = {
      use_template = [ "offsite" ];
      recursive = false;
    };
    "rsync-net:${rsyncNet.pool}/${rsyncNet.namespace}/db/mysql" = {
      use_template = [ "offsite" ];
      recursive = false;
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
      # Syncoid source permissions (pulled by yoda)
      zfs allow -u syncoid send,hold,snapshot,bookmark,mount ssd/db
      zfs allow -u syncoid send,hold,snapshot,bookmark,mount ssd/services/infra
      zfs allow -u syncoid send,hold,snapshot,bookmark,mount ssd/services/apps
      zfs allow -u syncoid send,hold,snapshot,bookmark,mount hdd/data/immich
      zfs allow -u syncoid send,hold,snapshot,bookmark,mount hdd/data/seafile
      zfs allow -u syncoid send,hold,snapshot,bookmark,mount hdd/data/paperless
      zfs allow -u syncoid send,hold,snapshot,bookmark,mount hdd/data/radicale

      # SSD pool defaults
      zfs set compression=zstd                 ssd
      zfs set atime=off                        ssd
      zfs set xattr=sa                         ssd
      zfs set acltype=posixacl                 ssd
      zfs set aclinherit=restricted            ssd
      zfs set aclmode=discard                  ssd
      zfs set dnodesize=auto                   ssd
      zfs set recordsize=16K                   ssd

      # Services defaults
      zfs create -p                            ssd/services 2>/dev/null || true
      zfs set mountpoint=none                  ssd/services
      zfs set quota=100G                       ssd/services

      # Infra overrides
      zfs create -p                            ssd/services/infra 2>/dev/null || true
      zfs set quota=10G                        ssd/services/infra

      # Apps overrides
      zfs create -p                            ssd/services/apps 2>/dev/null || true
      zfs set quota=50G                        ssd/services/apps

      # Databases defaults
      zfs create -p                            ssd/db 2>/dev/null || true
      zfs set mountpoint=none                  ssd/db
      zfs set quota=20G                        ssd/db
      zfs set logbias=latency                  ssd/db

      # Postgres overrides
      zfs create -p                            ssd/db/postgres 2>/dev/null || true
      zfs set quota=5G                         ssd/db/postgres
      zfs set recordsize=8K                    ssd/db/postgres

      # MySQL overrides
      zfs create -p                            ssd/db/mysql 2>/dev/null || true
      zfs set quota=1G                         ssd/db/mysql

      # Data defaults
      zfs create -p                            ssd/data 2>/dev/null || true
      zfs set mountpoint=none                  ssd/data
      zfs set quota=50G                        ssd/data

      # Loki overrides
      zfs create -p                            ssd/data/loki 2>/dev/null || true
      zfs set quota=30G                        ssd/data/loki

      # HDD pool defaults
      zfs set compression=zstd                 hdd
      zfs set atime=off                        hdd
      zfs set xattr=sa                         hdd
      zfs set acltype=posixacl                 hdd
      zfs set aclinherit=restricted            hdd
      zfs set aclmode=discard                  hdd
      zfs set dnodesize=auto                   hdd
      zfs set recordsize=1M                    hdd

      # Data defaults
      zfs create -p                            hdd/data 2>/dev/null || true
      zfs set mountpoint=none                  hdd/data
      zfs set quota=928G                       hdd/data

      # Media overrides
      zfs create -p                            hdd/data/media 2>/dev/null || true
      zfs set quota=800G                       hdd/data/media

      # Seafile overrides
      zfs create -p                            hdd/data/seafile 2>/dev/null || true
      zfs set quota=100G                       hdd/data/seafile

      # Paperless overrides
      zfs create -p                            hdd/data/paperless 2>/dev/null || true
      zfs set quota=50G                        hdd/data/paperless

      # Immich overrides
      zfs create -p                            hdd/data/immich 2>/dev/null || true
      zfs set quota=200G                       hdd/data/immich

      # Radicale overrides
      zfs create -p                            hdd/data/radicale 2>/dev/null || true
      zfs set quota=100M                       hdd/data/radicale
      [ "$(zfs get -H -o value mountpoint hdd/data/radicale)" = "/srv/data/radicale" ] \
        || zfs set mountpoint=/srv/data/radicale hdd/data/radicale
    '';
  };
}
