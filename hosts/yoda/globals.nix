{ lib, ... }:
let
  sharedGlobals = (import ../../modules/nixos/globals-shared.nix { })._module.args.globals;
  globals = lib.recursiveUpdate sharedGlobals {
    zfs = {
      data = {
        vaultwarden = {
          name = "ssd/data/vaultwarden";
          mountPoint = "/srv/data/vaultwarden";
        };
        loki = {
          name = "ssd/data/loki";
          mountPoint = "/srv/data/loki";
        };
        media = {
          name = "hdd/data/media";
          mountPoint = "/srv/data/media";
        };
        seafile = {
          name = "hdd/data/seafile";
          mountPoint = "/srv/data/seafile";
        };
        paperless = {
          name = "hdd/data/paperless";
          mountPoint = "/srv/data/paperless";
        };
        immich = {
          name = "hdd/data/immich";
          mountPoint = "/srv/data/immich";
        };
      };
    };
  };
in
{
  _module.args.globals = globals;
}
