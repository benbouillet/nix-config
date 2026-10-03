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
                mode = "mirror";
                members = [
                  "/dev/disk/by-id/ata-CT500MX500SSD1_2326E6E82F2D"
                  "/dev/disk/by-id/ata-CT500MX500SSD1_2326E6E82EE3"
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

      # HDD mirror for data/backup/archives
      hdd = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = [
                  "/dev/disk/by-id/ata-WDC_WD10EZEX-08WN4A0_WD-WCC6Y3CCPLFK"
                  "/dev/disk/by-id/ata-WDC_WD10EZEX-60WN4A0_WD-WCC6Y7XR5PV8"
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
          compression = "zstd";
          atime = "off";
          xattr = "sa";
          acltype = "posixacl";
          recordsize = "1M";
          encryption = "on";
          keyformat = "passphrase";
          keylocation = "prompt";
        };
      };
    };
  };
}
