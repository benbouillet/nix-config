{
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "mode=755"
      "size=4G"
      "nosuid"
      "nodev"
      "relatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/ESP";
    fsType = "vfat";
    options = [
      "umask=0077"
      "nodev"
      "nosuid"
      "noexec"
    ];
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-partlabel/nix";
    fsType = "ext4";
    options = [
      "noatime"
      "lazytime"
    ];
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-partlabel/persist";
    fsType = "ext4";
    options = [
      "noatime"
      "lazytime"
      "commit=30"
      "errors=remount-ro"
    ];
    neededForBoot = true;
  };

  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/log"
      "/var/lib/containers"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/var/lib/sops-nix/key.txt"
    ];
  };
}
