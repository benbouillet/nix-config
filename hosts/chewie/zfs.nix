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
}
