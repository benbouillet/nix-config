{
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko/nvme-root.nix
    ./disko/zfs-disks.nix
    ./disko/zpools.nix
    ./disko/datasets.nix
    ./zfs.nix
    ./reverse-proxy.nix
    ./services.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/server.nix
    ../../modules/nixos/ssd.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/tailscale.nix
  ];

  system.stateVersion = "24.05"; # DO NOT MODIFY
}
