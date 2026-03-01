{ ... }:
let
  globals = {
    domain = "r4clette.com";
    ports = {
      prometheus_exporters = {
        node = 9000;
        blackbox = 9115;
        zfs = 9116;
      };
    };
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
    podmanBridgeCIDR = "10.88.0.0/16";
  };
in
{
  _module.args.globals = globals;
}
