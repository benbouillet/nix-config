{
  host,
  ...
}:
{
  ########################################
  # Kernel & ZFS basics
  ########################################
  boot = {
    supportedFilesystems = [ "zfs" ];
    # Set this to false to disable ZFS decrypting at boot
    zfs = {
      requestEncryptionCredentials = true;
      extraPools = [
        "hdd"
        "ssd"
      ];
    };
  };

  # Reliable pool import
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" host);

  # ZFS housekeeping
  services.zfs = {
    autoScrub.enable = true; # monthly scrub (default schedule)
    trim.enable = true; # autotrim for SSD/NVMe
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
  zramSwap.enable = true;

  ########################################
  # Snapshot policy (sanoid)
  ########################################
  services.sanoid = {
    enable = true;
    templates.keep = {
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 3;
      autosnap = true;
      autoprune = true;
    };
    datasets = {
      "ssd/containers" = {
        useTemplate = [ "keep" ];
      };
    };
  };
}
