{
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko/zfs-disks.nix
    ./disko/zpools.nix
    ./zfs.nix
    ./impermanence.nix
    ./globals.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/server.nix
    ../../modules/nixos/ssd.nix
    ../../modules/nixos/zfs.nix
  ];

  system.stateVersion = "25.05"; # DO NOT MODIFY
}
