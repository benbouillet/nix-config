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
                  "/dev/disk/by-id/ata-SSDSC2BB960G7R_PHDV6515016X960FGN"
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
