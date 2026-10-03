{
  lib,
  config,
  pkgs,
  ...
}:
{
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.nvidia-container-toolkit.enable = true;

  nixpkgs = {
    config = {
      cudaSupport = true;
      cudaVersion = "12";
      cudaCapabilities = [ "12.0" ];
    };
  };

  nix = {
    settings = {
      substituters = lib.mkAfter [
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = lib.mkAfter [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
    };
  };
}
