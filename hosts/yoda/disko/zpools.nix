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
                mode = "raidz2";
                members = [
                  "/dev/disk/by-partlabel/disk-ssd1-ssd"
                  "/dev/disk/by-partlabel/disk-ssd2-ssd"
                  "/dev/disk/by-partlabel/disk-ssd3-ssd"
                  "/dev/disk/by-partlabel/disk-ssd4-ssd"
                  "/dev/disk/by-partlabel/disk-ssd5-ssd"
                  "/dev/disk/by-partlabel/disk-ssd6-ssd"
                  "/dev/disk/by-partlabel/disk-ssd7-ssd"
                  "/dev/disk/by-partlabel/disk-ssd8-ssd"
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
          encryption = "on";
          keyformat = "passphrase";
          keylocation = "prompt";
          logbias = "throughput";
          xattr = "sa";
        };
      };
    };
  };
}
