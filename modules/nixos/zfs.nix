{
  host,
  pkgs,
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

  environment.systemPackages = with pkgs; [
    lzop
    mbuffer
  ];

  ########################################
  # Sanoid
  ########################################
  services.sanoid = {
    enable = true;
    interval = "hourly";
    templates = {
      "nosnapshot" = {
        hourly = 0;
        daily = 0;
        weekly = 0;
        monthly = 0;
        autosnap = false;
        autoprune = true;
      };
      "standard" = {
        hourly = 24;
        daily = 7;
        weekly = 0;
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
        monthly = 1;
        yearly = 0;
        autosnap = true;
        autoprune = true;
      };
      "backup" = {
        autosnap = false;
        autoprune = true;
        hourly = 0;
        daily = 30;
        weekly = 8;
        monthly = 12;
      };
    };
  };
}
