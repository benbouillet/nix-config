{
  pkgs,
  host,
  ...
}:
{
  ########################################
  # Kernel & ZFS basics
  ########################################
  boot.supportedFilesystems = [ "zfs" ];

  # Reliable pool import
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" host);

  # ZFS housekeeping
  services.zfs = {
    autoScrub.enable = true;      # monthly scrub (default schedule)
    trim.enable = true;           # autotrim for SSD/NVMe
    zed.enable = true;            # ZFS event daemon (alerts)
  };

  ########################################
  # ARC cap (adjust for your RAM)
  ########################################
  # Example: cap ARC at ~8 GiB
  boot.kernelParams = [ "zfs.zfs_arc_max=17179869184" ];

  ########################################
  # VM host bits (optional but handy)
  ########################################
  virtualisation.libvirtd.enable = true;
  users.users.ben.extraGroups = [ "libvirtd" "kvm" ];
  zramSwap.enable = true;

  # Bridge for guests (edit NIC name if you want bridged networking)
  # networking.bridges.br0.interfaces = [ "enp3s0" ];
  # networking.interfaces.br0.useDHCP = true;

  ########################################
  # Snapshot policy (sanoid)
  ########################################
  services.sanoid = {
    enable = true;
    templates.keep = {
      hourly = 24; daily = 7; weekly = 4; monthly = 3;
      autosnap = true; autoprune = true;
    };
    datasets = {
      "vm/images"     = { useTemplate = [ "keep" ]; };
      "data/backups"  = { useTemplate = [ "keep" ]; };
      "rpool/var"     = { hourly = 6; daily = 1; autosnap = true; autoprune = true; };
      "rpool/var/log" = { autosnap = false; autoprune = true; };
    };
  };

  # Optional: syncoid example (replicate to another host)
  # services.syncoid = {
  #   enable = true;
  #   jobs."vm/images->backuphost:vm/images" = { recursive = true; };
  # };

  # Target that depends will be started AFTER you unlock & mount
  systemd.targets."after-zfs-unlock".description = "Services that require encrypted ZFS datasets";

  # One-shot you run manually after boot to unlock and mount
  systemd.services."zfs-unlock" = {
    description = "Manually unlock ZFS encrypted datasets and mount them";
    after  = [ "zfs-import-cache.service" "zfs-import-scan.service" "network-online.target" ];
    before = [ "after-zfs-unlock.target" ];
    serviceConfig = {
      Type = "oneshot";
      # This will PROMPT you for each encryption root (vm, data) because keylocation=prompt
      ExecStart = ''
        ${pkgs.zfs}/bin/zfs load-key -a \
        ${pkgs.zfs}/bin/zfs mount -a
      '';
    };
  };

  # Example: make libvirtd wait until datasets are available
  # systemd.services.libvirtd = {
  #   after = [ "after-zfs-unlock.target" ];
  #   wants = [ "after-zfs-unlock.target" ];
  # };
}
