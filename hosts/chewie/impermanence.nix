{
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=4G"
        "mode=0755"
      ];
    };

    disk = {
      nvme0 = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_1TB_S649NL0W136843P";
        type = "disk";

        content = {
          type = "gpt";
          partitions = {
            boot = {
              priority = 1;
              name = "boot";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                  "nodev"
                  "nosuid"
                  "noexec"
                ];
              };
            };
            data = {
              size = "100%";
              content = {
                type = "btrfs";
                subvolumes = {
                  nix = {
                    type = "filesystem";
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" ];
                  };
                  persist = {
                    type = "filesystem";
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/lib"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
