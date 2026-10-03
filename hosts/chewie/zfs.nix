{
  globals,
  pkgs,
  lib,
  ...
}:
let
  yodaToChewiePublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBULf9dIT77X0zgCIIvFN/CORkEckj47Fn1mTc3AfFtY root@yoda";
  rsyncNet = globals.rsyncNet;

  # ZFS dataset layout — properties applied by zfs-datasets-options-setup
  # Order matters: parents must come before children
  zfsDatasets = [
    # SSD pool defaults
    {
      ds = "ssd";
      props = {
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
      ds = "ssd/services";
      props = {
        mountpoint = "none";
        quota = "100G";
      };
      create = true;
      localSnapshots = {
        use_template = [ "standard" ];
        recursive = true;
      };
    }
    {
      ds = "ssd/services/infra";
      props = {
        quota = "10G";
      };
      mountpoint = "/srv/services/infra";
      create = true;
    }
    {
      ds = "ssd/services/apps";
      props = {
        quota = "50G";
      };
      mountpoint = "/srv/services/apps";
      create = true;
      localSnapshots = {
        use_template = [ "standard" ];
      };
    }
    {
      ds = "ssd/db";
      props = {
        mountpoint = "none";
        quota = "20G";
        logbias = "latency";
      };
      create = true;
      localSnapshots = {
        use_template = [ "highchurn" ];
        recursive = true;
      };
    }
    {
      ds = "ssd/db/postgres";
      props = {
        quota = "5G";
        recordsize = "8K";
      };
      mountpoint = "/srv/db/postgres";
      create = true;
    }
    {
      ds = "ssd/db/mysql";
      props = {
        quota = "1G";
      };
      mountpoint = "/srv/db/mysql";
      create = true;
    }
    # HDD pool defaults
    {
      ds = "hdd";
      props = {
        compression = "zstd";
        atime = "off";
        xattr = "sa";
        acltype = "posixacl";
        aclinherit = "restricted";
        aclmode = "discard";
        dnodesize = "auto";
        recordsize = "1M";
      };
    }
    {
      ds = "hdd/data";
      props = {
        mountpoint = "none";
        quota = "928G";
      };
      create = true;
      localSnapshots = {
        use_template = [ "cold" ];
        recursive = true;
      };
    }
    {
      ds = "hdd/data/media";
      props = {
        quota = "800G";
      };
      mountpoint = "/srv/data/media";
      create = true;
      localSnapshots = {
        use_template = [ "nosnapshot" ];
      };
    }
    {
      ds = "hdd/data/seafile";
      props = {
        quota = "100G";
      };
      mountpoint = "/srv/data/seafile";
      create = true;
      localSnapshots = {
        use_template = [ "standard" ];
      };
    }
    {
      ds = "hdd/data/paperless";
      props = {
        quota = "50G";
      };
      mountpoint = "/srv/data/paperless";
      create = true;
      localSnapshots = {
        use_template = [ "standard" ];
      };
    }
    {
      ds = "hdd/data/immich";
      props = {
        quota = "200G";
      };
      mountpoint = "/srv/data/immich";
      create = true;
      localSnapshots = {
        use_template = [ "standard" ];
      };
    }
    {
      ds = "hdd/data/radicale";
      props = {
        quota = "100M";
      };
      mountpoint = "/srv/data/radicale";
      create = true;
      localSnapshots = {
        use_template = [ "standard" ];
      };
    }
  ];

  ########################################
  # Backups pulled from yoda
  ########################################
  # Datasets yoda is allowed to pull via syncoid
  syncoidAllow = [
    "ssd/db"
    "ssd/services/infra"
    "ssd/services/apps"
    "hdd/data/immich"
    "hdd/data/seafile"
    "hdd/data/paperless"
    "hdd/data/radicale"
  ];

  ########################################
  # Backups pushed to rsync.net
  ########################################
  offsiteBackups = [
    {
      source = "ssd/db";
      target = "rsync-net:${rsyncNet.pool}/${rsyncNet.namespace}/db";
      extraArgs = [ "--recursive" ];
      sanoid = {
        use_template = [ "offsite" ];
        recursive = true;
      };
    }
  ];

  syncoidOffsitePush = builtins.listToAttrs (
    map (e: {
      name = e.source;
      value = { inherit (e) source target extraArgs; };
    }) offsiteBackups
  );

  offsiteSanoidSnapshots = builtins.listToAttrs (
    map (e: {
      name = e.target;
      value = e.sanoid;
    }) offsiteBackups
  );

  # Derived from zfsDatasets entries that have a localSnapshots field
  localSanoidSnapshots = builtins.listToAttrs (
    lib.concatMap (
      entry:
      lib.optional (entry ? localSnapshots) {
        name = entry.ds;
        value = entry.localSnapshots;
      }
    ) zfsDatasets
  );

  # Generates the shell snippet for one dataset entry
  mkDatasetScript =
    {
      ds,
      props,
      mountpoint ? null,
      create ? false,
      ...
    }:
    let
      createLine = lib.optionalString create "zfs create -p ${ds} 2>/dev/null || true";
      propLines = lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "zfs set ${k}=${v} ${ds}") props);
      mountLine = lib.optionalString (mountpoint != null) ''
        [ "$(zfs get -H -o value mountpoint ${ds})" = "${mountpoint}" ] \
          || zfs set mountpoint=${mountpoint} ${ds}'';
    in
    lib.concatStringsSep "\n" (
      lib.filter (s: s != "") [
        createLine
        propLines
        mountLine
      ]
    );
in
{
  ########################################
  # ZFS pools & kernel
  ########################################
  boot.zfs.extraPools = [
    "hdd"
    "ssd"
  ];

  # Cap ARC at 16 GiB
  boot.kernelParams = [ "zfs.zfs_arc_max=17179869184" ];

  ########################################
  # Prometheus exporter
  ########################################
  services.prometheus.exporters.zfs = {
    enable = true;
    telemetryPath = "/metrics";
    listenAddress = "0.0.0.0";
    port = globals.ports.prometheus_exporters.zfs;
  };

  ########################################
  # Sanoid snapshots (local && offsite)
  # * Creates local snapshots
  # * Prunes old local snapshots
  # * Prunes old snapshots on rsync.net
  ########################################
  services.sanoid.datasets = localSanoidSnapshots // offsiteSanoidSnapshots;

  ########################################
  # Syncoid — pulled by yoda
  # yoda SSHes in as syncoid to replicate
  # local datasets to itself
  ########################################
  users.users.syncoid = {
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [ yodaToChewiePublicKey ];
  };

  ########################################
  # Syncoid — offsite push to rsync.net
  # SSH alias "rsync-net" is defined in the
  # ssh-config secret (hostname kept private)
  ########################################

  # SSH credentials & config for rsync.net (hostname kept out of the public repo)
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

  # Make the "rsync-net" SSH alias available system-wide via Include
  programs.ssh.extraConfig = "Include /run/secrets/rsync-net/ssh-config";

  # Ensure the remote namespace dataset exists before syncoid runs
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
    localTargetAllow = [ ]; # target is remote — suppress local zfs-allow attempts
    localSourceAllow = [ ]; # permissions managed by zfs-datasets-options-setup instead
    commonArgs = [
      "--no-sync-snap"
      "--compress=zstd-fast"
      "--no-resume"
      "--quiet"
    ];
    commands = syncoidOffsitePush;
  };

  systemd.services."syncoid-offsite-db" = {
    after = [ "rsync-net-datasets-setup.service" ];
    requires = [ "rsync-net-datasets-setup.service" ];
  };

  ########################################
  # ZFS dataset options & layout
  # Runs before zfs-mount so datasets are
  # configured before services start
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
      ${lib.concatMapStringsSep "\n" (
        ds: "zfs allow -u syncoid send,hold,snapshot,bookmark,mount ${ds}"
      ) syncoidAllow}

      # Dataset properties & layout
      ${lib.concatMapStringsSep "\n\n" mkDatasetScript zfsDatasets}
    '';
  };
}
