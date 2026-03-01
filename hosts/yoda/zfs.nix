{
  globals,
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
  sops.secrets."ssh/yoda_to_chewie_syncoid_key_priv" = {
    owner = "root";
    group = "root";
    mode = "0400";
    path = "/root/.ssh/chewie_root_ed25519";
  };

  environment.etc."ssh/ssh_config.d/20-chewie.conf".text = ''
    Host chewie
      HostName chewie
      User root
      IdentityFile /root/.ssh/chewie_root_ed25519
      IdentitiesOnly yes
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
