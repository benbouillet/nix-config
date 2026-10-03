{ lib, ... }:
let
  sharedGlobals = (import ../../modules/nixos/globals-shared.nix { })._module.args.globals;
  globals = lib.recursiveUpdate sharedGlobals {
    zfs = {
      databases = {
        postgres = {
          name = "ssd/db/postgres";
          mountPoint = "/srv/db/postgres";
        };
        mysql = {
          name = "ssd/db/mysql";
          mountPoint = "/srv/db/mysql";
        };
      };
      services = {
        infra = {
          name = "ssd/services/infra";
          mountPoint = "/srv/services/infra";
        };
        apps = {
          name = "ssd/services/apps";
          mountPoint = "/srv/services/apps";
        };
      };
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
        radicale = {
          name = "hdd/data/radicale";
          mountPoint = "/srv/data/radicale";
        };
      };
    };
    podmanBridgeCIDR = "10.88.0.0/16";
    podmanBridgeGateway = "10.88.0.1";
    rsyncNet = {
      pool = "data1";
      namespace = "chewie";
    };
  };
in
{
  _module.args.globals = globals;
}
