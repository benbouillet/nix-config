{
  globals,
  pkgs,
  config,
  ...
}:
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
  # Syncoid to yoda
  ########################################
  sops.secrets."ssh/yoda_to_chewie_syncoid_key_pub" = {
    owner = "root";
    group = "root";
    mode  = "0644"; # public key file is fine to be world-readable
    path  = "/etc/ssh/authorized_keys.d/root";
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
      zfs set compression=zstd                 ssd
      zfs set atime=off                        ssd
      zfs set xattr=sa                         ssd
      zfs set acltype=posixacl                 ssd
      zfs set aclinherit=restricted            ssd
      zfs set aclmode=discard                  ssd
      zfs set dnodesize=auto                   ssd
      zfs set recordsize=16K                   ssd

      # Services defaults
      zfs set mountpoint=none                  ssd/services
      zfs set quota=100G                       ssd/services

      # Infra overrides
      zfs set quota=10G                        ssd/services/infra

      # Apps overrides
      zfs set quota=50G                        ssd/services/apps

      # Databases defaults
      zfs set mountpoint=none                  ssd/db
      zfs set quota=20G                        ssd/db
      zfs set logbias=latency                  ssd/db

      # Postgres overrides
      zfs set quota=5G                         ssd/db/postgres
      zfs set recordsize=8K                    ssd/db/postgres

      # MySQL overrides
      zfs set quota=1G                         ssd/db/mysql

      # Data defaults
      zfs set mountpoint=none                  ssd/data
      zfs set quota=50G                        ssd/data

      # Loki overrides
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
      zfs set mountpoint=none                  hdd/data
      zfs set quota=928G                       hdd/data

      # Media overrides
      zfs set quota=800G                       hdd/data/media

      # Seafile overrides
      zfs set quota=100G                       hdd/data/seafile

      # Paperless overrides
      zfs set quota=50G                        hdd/data/paperless

      # Immich overrides
      zfs set quota=200G                       hdd/data/immich
    '';
  };
}
