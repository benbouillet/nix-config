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
    ./gpu.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/server.nix
    ../../modules/nixos/ssd.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/tailscale.nix
    ../../modules/nixos/services/reverse-proxy.nix
    ../../modules/nixos/services/containers/common.nix
    ../../modules/nixos/services/containers/debug.nix
    ../../modules/nixos/services/containers/arr.nix
    ../../modules/nixos/services/llm.nix
  ];

  system.stateVersion = "24.05"; # DO NOT MODIFY
}
