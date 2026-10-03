{ lib, ... }:
let
  sharedGlobals = (import ../../modules/nixos/globals-shared.nix { })._module.args.globals;
  globals = lib.recursiveUpdate sharedGlobals {
    zfs = {
      data = {
        loki = {
          name = "ssd/data/loki";
          mountPoint = "/srv/data/loki";
        };
      };
    };
  };
in
{
  _module.args.globals = globals;
}
