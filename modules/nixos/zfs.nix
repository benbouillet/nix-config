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
      "standard" = {
        hourly = 24;
        daily = 7;
        weekly = 3;
        monthly = 0;
        autosnap = true;
        autoprune = true;
      };
      "highchurn" = {
        hourly = 12;
        daily = 7;
        weekly = 0;
        monthly = 0;
        autosnap = true;
        autoprune = true;
      };
      "cold" = {
        hourly = 0;
        daily = 7;
        weekly = 4;
        monthly = 6;
        yearly = 1;
        autosnap = true;
        autoprune = true;
      };
    };
  };
}
