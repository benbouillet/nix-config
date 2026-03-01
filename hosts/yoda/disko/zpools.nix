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
                  "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544102JR800HGN"
                  "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544102FU800HGN"
                  "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544104JK800HGN"
                  "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA5441052J800HGN"
                  "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544102L9800HGN"
                  "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544102JF800HGN"
                  "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544204T5800HGN"
                  "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544205P1800HGN"
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
