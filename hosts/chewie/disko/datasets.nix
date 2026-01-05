{
  disko.devices = {
    zpool = {
      # SSD mirror for ssd storage
      ssd = {
        datasets = {
          "containers" = {
            type = "zfs_fs";
            options = {
              recordsize = "16K";
              quota = "100GB";
              mountpoint = "/srv/containers";
            };
          };
          "media" = {
            type = "zfs_fs";
            options = {
              recordsize = "1M";
              quota = "500GB";
              mountpoint = "/srv/media";
            };
          };
        };
      };

      # HDD mirror for data/backup/archives
      hdd = {
        datasets = {
          "backups" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/srv/backups";
              quota = "100GB";
            };
          };
          "media" = {
            type = "zfs_fs";
            options = {
              recordsize = "1M";
              quota = "500GB";
              mountpoint = "/srv/media";
            };
          };
        };
      };
    };
  };
}
