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
  # VM host bits (optional but handy)
  ########################################
  virtualisation.libvirtd.enable = true;
  zramSwap.enable = true;

  services.sanoid = {
    enable = true;
    interval = "hourly";
    templates = {
      "containers" = {
        autosnap = true;
        autoprune = true;
        hourly = 6;
        daily = 3;
        weekly = 2;
      };
    };
  };
}
