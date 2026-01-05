{
  disko.devices = {
    disk = {
      nvme0 = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_1TB_S649NL0W136843P";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              start = "0%";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" "nodev" "nosuid" "noexec" ];
              };
            };
            root = {
              name = "root";
              type = "8300";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [ "noatime" "lazytime" "commit=30" "errors=remount-ro" ];
              };
            };
          };
        };
      };
    };
  };
}
