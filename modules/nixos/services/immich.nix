{
  globals,
  pkgs,
  config,
  lib,
  ...
}:
{
  sops.secrets."immich/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  services.postgresql = {
    enable = lib.mkForce true;
    ensureDatabases = lib.mkAfter [
      "immich"
    ];
    ensureUsers = lib.mkAfter [
      {
        name = "immich";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
          connection_limit = 20;
          password = "SCRAM-SHA-256$4096:g+/4rpVJ32ZsfNpL6CngtA==$SaD88N7LAPYhWVjRrh2h5ERyD1o2OT3DDdus/wAE6+c=:XRISloNwAn0r2YQ3YDxcVpU4T/hNRmORHJE0AKfh1r0=";
        };
      }
    ];
  };

  systemd.services."immich-server" = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  users.users.immich.extraGroups = [ "video" "render" ];

  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = globals.ports.immich;
    mediaLocation = globals.zfs.data.immich.mountPoint;
    accelerationDevices = [ "pci-0000:01:00.0-render" ];
    database = {
      enable = false;
      host = "127.0.0.1";
      port = globals.ports.postgres;
      user = "immich";
      name = "immich";
      enableVectors = false;
    };
    redis = {
      enable = false;
      host = "127.0.0.1";
      port = globals.ports.redis;
    };
    settings = {
      server.externalDomain = "https://images.${globals.domain}";
    };
    secretsFile = config.sops.secrets."immich/env".path;
    environment = {
      DB_HOST = "127.0.0.1";
      DB_PORT = toString globals.ports.postgres;
      DB_USERNAME = "immich";
      DB_DATABASE_NAME = "immich";
      DB_STORAGE_TYPE = "SSD";

      IMMICH_LOG_LEVEL = "error";
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @images host images.${globals.domain}
    handle @images {
      reverse_proxy 127.0.0.1:${toString globals.ports.immich}
    }
  '';
}
