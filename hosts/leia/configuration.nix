{
  ...
}:
{
  imports = [
    ./disko/zpools.nix
    ./disko/zfs-disks.nix
    ./hardware-configuration.nix
    ./zfs.nix
    ./impermanence.nix
    ./globals.nix
    ./reverse-proxy.nix
    ./caddy-services.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/server.nix
    ../../modules/nixos/ssd.nix
    ../../modules/nixos/zfs.nix
  ];

  system.stateVersion = "25.05"; # DO NOT MODIFY
}
