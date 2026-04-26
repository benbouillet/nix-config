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
    ../../modules/nixos/observability/prometheus.nix
    ../../modules/nixos/observability/grafana.nix
    ../../modules/nixos/observability/loki.nix
    ../../modules/nixos/services/ntfy.nix
  ];

  system.stateVersion = "25.05"; # DO NOT MODIFY
}
