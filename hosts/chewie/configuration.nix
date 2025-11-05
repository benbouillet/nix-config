{
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./zfs.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/server.nix
    ../../modules/nixos/ssd.nix
  ];

  system.stateVersion = "24.05"; # DO NOT MODIFY
}
