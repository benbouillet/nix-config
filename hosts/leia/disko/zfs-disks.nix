{
  disko.devices = {
    disk = {
      ssd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SSDSC2BB960G7R_PHDV6515016X960FGN";
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
