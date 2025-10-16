{
  disko.devices = {
    ########################################
    # PHYSICAL DISKS (edit the by-id paths)
    ########################################
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

      ssd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-CT500MX500SSD1_2326E6E82F2D";
        content = {
          type = "gpt";
          partitions = {
            vm = {
              size = "100%";
              type = "BF01";
              content = { type = "zfs"; pool = "vm"; };
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
            vm = {
              size = "100%";
              type = "BF01";
              content = { type = "zfs"; pool = "vm"; };
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
            data = {
              size = "100%";
              type = "BF01";
              content = { type = "zfs"; pool = "data"; };
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
            data = {
              size = "100%";
              type = "BF01";
              content = { type = "zfs"; pool = "data"; };
            };
          };
        };
      };
    };

    ########################################
    # ZFS POOLS + DATASETS
    ########################################
    zpool = {
      # SSD mirror for VM storage
      vm = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [{
              mode = "mirror";
              members = [
                "/dev/disk/by-partlabel/disk-ssd1-vm"
                "/dev/disk/by-partlabel/disk-ssd2-vm"
              ];
            }];
          };
        };

        options = { ashift = "12"; autotrim = "on"; };

        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          compression = "zstd";
          encryption   = "on";
          keyformat    = "passphrase";
          keylocation  = "prompt";
          logbias = "throughput";
          xattr = "sa";
        };

        datasets = {
          # file-based VM images live here (raw or qcow2). For KVM, raw + 16K works great.
          "vm/images" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/libvirt/images";
            options = { recordsize = "16K"; };
          };
          # Optional place for ISO files on SSD if you want fast installs:
          "vm/iso" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/libvirt/iso";
          };
        };
      };

      # HDD mirror for data/backup/archives
      data = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [{
              mode = "mirror";
              members = [
                "/dev/disk/by-partlabel/disk-hdd1-data"
                "/dev/disk/by-partlabel/disk-hdd2-data"
              ];
            }];
          };
        };
        options = { ashift = "12"; autotrim = "on"; };
        rootFsOptions = {
          compression = "zstd";
          atime = "off";
          xattr = "sa";
          acltype = "posixacl";
          recordsize = "1M";   # great for large files/backups/media
          encryption   = "on";
          keyformat    = "passphrase";
          keylocation  = "prompt";
        };

        datasets = {
          "data/isos"    = { type = "zfs_fs"; mountpoint = "/srv/isos"; };
          "data/backups" = { type = "zfs_fs"; mountpoint = "/srv/backups"; };
          "data/archive" = { type = "zfs_fs"; mountpoint = "/srv/archive"; };
        };
      };
    };
  };
}
