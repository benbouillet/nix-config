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
    "d ${?????????????}/paperless/data 2770 root ${globals.groups.containers.name} - -"
    "d ${?????????????}/paperless/consume 2770 root ${globals.groups.containers.name} - -"
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
      image = "ghcr.io/paperless-ngx/paperless-ngx:2.20.13";
      ports = [
        "127.0.0.1:${toString globals.ports.paperless}:8000"
      ];
      volumes = [
        "${?????????????}/paperless/data:/usr/src/paperless/data:rw"
        "${globals.zfs.data.paperless.mountPoint}:/usr/src/paperless/media:rw"
        "${?????????????}/paperless/consume:/usr/src/paperless/consume:rw"
      ];
      environment = {
        PAPERLESS_REDIS = "redis://host.containers.internal:${toString globals.ports.redis}";
        PAPERLESS_REDIS_PREFIX = "paperless";
        PAPERLESS_DBHOST = "host.containers.internal";
        PAPERLESS_DBPORT = toString globals.ports.postgres;
        PAPERLESS_DBENGINE = "postgresql";
        PAPERLESS_DBUSER = "paperless";
        PAPERLESS_URL = "https://docs.${globals.domain}";
        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        PAPERLESS_ADMIN_USER = "admin";
        PAPERLESS_SOCIAL_ACCOUNT_SYNC_GROUPS = "true";
        PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS = "true";
        PAPERLESS_SOCIAL_AUTO_SIGNUP = "true";
        PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = "false";
        PAPERLESS_DISABLE_REGULAR_LOGIN = "true";
        PAPERLESS_LOGOUT_REDIRECT_URL = "https://auth.${globals.domain}/logout";
        PAPERLESS_ACCOUNT_DEFAULT_GROUPS = "paperless-users";
        PAPERLESS_SOCIAL_ACCOUNT_DEFAULT_GROUPS = "paperless-users";
        PAPERLESS_OCR_LANGUAGE = "fra+eng";
      };
      environmentFiles = [ config.sops.secrets."services/paperless/env".path ];
      extraOptions = [
        "--memory=768m"
        "--memory-swap=512m"
        "--pids-limit=64"
      ];
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "docs.${globals.domain}";
        policy = "one_factor";
        subject = "group:paperless";
      }
    ];

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

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @docs host docs.${globals.domain}
    handle @docs {
      reverse_proxy 127.0.0.1:${toString globals.ports.paperless}
    }
  '';
}
