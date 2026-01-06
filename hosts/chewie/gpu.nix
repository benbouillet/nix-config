{
  lib,
  ...
}:
{
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  hardware.nvidia-container-toolkit.enable = true;

  nixpkgs = {
    config = {
      cudaSupport = true;
      cudaVersion = "12";
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
