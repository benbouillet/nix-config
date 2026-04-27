{
  lib,
  config,
  globals,
  ...
}:
{
  sops.secrets."services/paperless/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.services.apps.mountPoint}/paperless 2770 1000 1000 - -"
  ];

  services = {
    postgresql = {
      enable = lib.mkForce true;
      ensureDatabases = lib.mkAfter [
        "paperless"
      ];
      ensureUsers = lib.mkAfter [
        {
          name = "paperless";
          ensureDBOwnership = true;
          ensureClauses = {
            createrole = true;
            createdb = true;
            connection_limit = 20;
          };
        }
      ];
    };
  };

  virtualisation.oci-containers.containers = {
    "paperless" = {
      image = "ghcr.io/paperless-ngx/paperless-ngx:2.20.15@sha256:6c86cad803970ea782683a8e80e7403444c5bf3cf70de63b4d3c8e87500db92f";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.paperless}:8000"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/paperless:/usr/src/paperless/data:rw"
        "${globals.zfs.data.paperless.mountPoint}:/usr/src/paperless/media:rw"
        "paperless-consume:/usr/src/paperless/consume:rw"
      ];
      environment = {
        PAPERLESS_REDIS = "redis://database:${toString globals.ports.redis}";
        PAPERLESS_REDIS_PREFIX = "paperless";
        PAPERLESS_DBHOST = "database";
        PAPERLESS_DBPORT = toString globals.ports.postgres;
        PAPERLESS_DBENGINE = "postgresql";
        PAPERLESS_DBUSER = "paperless";
        PAPERLESS_URL = "https://paperless.${globals.domain}";
        PAPERLESS_ADMIN_USER = "ben";
        PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = "false";
        PAPERLESS_OCR_LANGUAGE = "fra+eng";
      };
      environmentFiles = [ config.sops.secrets."services/paperless/env".path ];
      extraOptions = [
        "--memory=2048m"
        "--pids-limit=64"
        "--add-host=database:host-gateway"
      ];
    };
  };

  systemd.services."podman-paperless" = {
    after = [
      "postgresql.service"
      "redis-raclette.service"
    ];
    requires = [
      "postgresql.service"
      "redis-raclette.service"
    ];
  };

  
}
