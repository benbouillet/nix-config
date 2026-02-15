{
  host,
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
}
