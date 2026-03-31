{
  disko.devices = {
    ########################################
    # ZFS POOLS + DATASETS
    ########################################
    zpool = {
      # SSD mirror for ssd storage
      ssd = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                members = [
                  "/dev/disk/by-partlabel/disk-ssd1-ssd"
                ];
              }
            ];
          };
        };

        options = {
          ashift = "12";
          autotrim = "on";
        };

        rootFsOptions = {
          mountpoint = "none";
          canmount = "off";
          acltype = "posixacl";
          atime = "off";
          compression = "zstd";
          logbias = "throughput";
          xattr = "sa";
        };
      };
    };
  };
}
