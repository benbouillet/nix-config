{
  disko.devices = {
    disk = {
      ssd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-CT500MX500SSD1_2326E6E82F2D";
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
        device = "/dev/disk/by-id/ata-CT500MX500SSD1_2326E6E82EE3";
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

      hdd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD10EZEX-08WN4A0_WD-WCC6Y3CCPLFK";
        content = {
          type = "gpt";
          partitions = {
            hdd = {
              size = "100%";
              type = "BF01";
              content = {
                type = "zfs";
                pool = "hdd";
              };
            };
          };
        };
      };
      hdd2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD10EZEX-60WN4A0_WD-WCC6Y7XR5PV8";
        content = {
          type = "gpt";
          partitions = {
            hdd = {
              size = "100%";
              type = "BF01";
              content = {
                type = "zfs";
                pool = "hdd";
              };
            };
          };
        };
      };
    };
  };
}
