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
              start = "1MiB"; end = "513MiB"; type = "EF00";
              content = {
                type = "filesystem"; format = "vfat";
                mountpoint = "/boot"; mountOptions = [ "umask=0077" ];
              };
            };
            rpool = { name = "rpool"; start = "513MiB"; end = "100%"; type = "BF01"; }; # ZFS
          };
        };
      };

      ssd1 = {
        device = "/dev/disk/by-id/ata-SSD500G-CHANGE1";
        type = "disk"; content = { type = "gpt"; partitions = { vm = { start = "1MiB"; end = "100%"; type = "BF01"; }; }; };
      };
      ssd2 = {
        device = "/dev/disk/by-id/ata-SSD500G-CHANGE2";
        type = "disk"; content = { type = "gpt"; partitions = { vm = { start = "1MiB"; end = "100%"; type = "BF01"; }; }; };
      };

      hdd1 = {
        device = "/dev/disk/by-id/ata-HDD1TB-CHANGE1";
        type = "disk"; content = { type = "gpt"; partitions = { data = { start = "1MiB"; end = "100%"; type = "BF01"; }; }; };
      };
      hdd2 = {
        device = "/dev/disk/by-id/ata-HDD1TB-CHANGE2";
        type = "disk"; content = { type = "gpt"; partitions = { data = { start = "1MiB"; end = "100%"; type = "BF01"; }; }; };
      };
    };

    ########################################
    # ZFS POOLS + DATASETS
    ########################################
    zpool = {
      # Root on NVMe
      rpool = {
        mode = "single";
        vdevs = [ "disk/nvme0:part:rpool" ];
        options = { ashift = "12"; autotrim = "on"; };
        rootFsOptions = {
          compression = "zstd";
          atime = "off";
          xattr = "sa";
          acltype = "posixacl";
          dnodesize = "auto";
        };
        datasets = {
          "rpool/ROOT" = { mountpoint = "none"; };
          "rpool/ROOT/nixos" = { mountpoint = "/"; };
          "rpool/nix"  = { mountpoint = "/nix";  options = { atime = "on"; recordsize = "16K"; }; };
          "rpool/var"  = { mountpoint = "/var"; };
          "rpool/var/log" = { mountpoint = "/var/log";  options = { quota = "2G"; }; };
          "rpool/home" = { mountpoint = "/home"; };
        };
      };

      # SSD mirror for VM storage
      vm = {
        mode = "mirror";
        vdevs = [ [ "disk/ssd1:part:vm" "disk/ssd2:part:vm" ] ];
        options = { ashift = "12"; autotrim = "on"; };
        rootFsOptions = {
          compression = "zstd";
          atime = "off";
          xattr = "sa";
          acltype = "posixacl";
          logbias = "throughput";
          encryption   = "on";
          keyformat    = "passphrase";
          keylocation  = "prompt";
        };
        datasets = {
          # file-based VM images live here (raw or qcow2). For KVM, raw + 16K works great.
          "vm/images" = { mountpoint = "/var/lib/libvirt/images"; options = { recordsize = "16K"; }; };
          # Optional place for ISO files on SSD if you want fast installs:
          "vm/iso"    = { mountpoint = "/var/lib/libvirt/iso"; };
          # If you prefer ZVOLs per-VM, you'll create them later (see notes).
        };
      };

      # HDD mirror for data/backup/archives
      data = {
        mode = "mirror";
        vdevs = [ [ "disk/hdd1:part:data" "disk/hdd2:part:data" ] ];
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
          "data/isos"    = { mountpoint = "/srv/isos"; };
          "data/backups" = { mountpoint = "/srv/backups"; };
          "data/archive" = { mountpoint = "/srv/archive"; };
        };
      };
    };
  };
}
