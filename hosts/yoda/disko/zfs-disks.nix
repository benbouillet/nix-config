{
  disko.devices = {
    disk = {
      ssd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544102JR800HGN";
        content = {
          type = "gpt";
          partitions = {
            ssd = {
              size = "100%";
              type = "BF01";
              content = {
                type = "zfs";
                pool = "ssd";
              };
            };
          };
        };
      };
      ssd2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544102FU800HGN";
        content = {
          type = "gpt";
          partitions = {
            ssd = {
              size = "100%";
              type = "BF01";
              content = {
                type = "zfs";
                pool = "ssd";
              };
            };
          };
        };
      };
      ssd3 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544104JK800HGN";
        content = {
          type = "gpt";
          partitions = {
            ssd = {
              size = "100%";
              type = "BF01";
              content = {
                type = "zfs";
                pool = "ssd";
              };
            };
          };
        };
      };
      ssd4 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA5441052J800HGN";
        content = {
          type = "gpt";
          partitions = {
            ssd = {
              size = "100%";
              type = "BF01";
              content = {
                type = "zfs";
                pool = "ssd";
              };
            };
          };
        };
      };
      ssd5 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544102L9800HGN";
        content = {
          type = "gpt";
          partitions = {
            ssd = {
              size = "100%";
              type = "BF01";
              content = {
                type = "zfs";
                pool = "ssd";
              };
            };
          };
        };
      };
      ssd6 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544102JF800HGN";
        content = {
          type = "gpt";
          partitions = {
            ssd = {
              size = "100%";
              type = "BF01";
              content = {
                type = "zfs";
                pool = "ssd";
              };
            };
          };
        };
      };
      ssd7 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544204T5800HGN";
        content = {
          type = "gpt";
          partitions = {
            ssd = {
              size = "100%";
              type = "BF01";
              content = {
                type = "zfs";
                pool = "ssd";
              };
            };
          };
        };
      };
      ssd8 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-INTEL_SSDSC2BB800G6_BTWA544205P1800HGN";
        content = {
          type = "gpt";
          partitions = {
            ssd = {
              size = "100%";
              type = "BF01";
              content = {
                type = "zfs";
                pool = "ssd";
              };
            };
          };
        };
      };
    };
  };
}
