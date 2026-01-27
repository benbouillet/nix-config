{
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko/nvme-root.nix
    ./zfs.nix
    ./gpu.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/server.nix
    ../../modules/nixos/ssd.nix
    ../../modules/nixos/tailscale.nix
    ../../modules/nixos/services/reverse-proxy.nix
    ../../modules/nixos/services/postgresql.nix
    ../../modules/nixos/services/authentication.nix
    ../../modules/nixos/services/containers/common.nix
    ../../modules/nixos/services/containers/arr.nix
    ../../modules/nixos/services/containers/ai.nix
    ../../modules/nixos/services/containers/search.nix
    ../../modules/nixos/services/containers/nextcloud.nix
    ../../modules/nixos/services/containers/steam.nix
    ../../modules/nixos/services/containers/debug.nix
  ];

  system.stateVersion = "24.05"; # DO NOT MODIFY
}
