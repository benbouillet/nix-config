{
  lib,
  config,
  globals,
  ...
}:
{
  sops.secrets."services/mealie/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.services.apps.mountPoint}/mealie 2770 1000 1000 - -"
  ];

  services = {
    postgresql = {
      enable = lib.mkForce true;
      ensureDatabases = lib.mkAfter [
        "mealie"
      ];
      ensureUsers = lib.mkAfter [
        {
          name = "mealie";
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
    "mealie" = {
      image = "ghcr.io/mealie-recipes/mealie:v3.14.0";
      ports = [
        "127.0.0.1:${toString globals.ports.mealie}:9000"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/mealie:/app/data/"
      ];
      environment = {
        ALLOW_SIGNUP = "false";
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Paris";
        BASE_URL = "https://mealie.${globals.domain}";
        DB_ENGINE = "postgres";
        POSTGRES_USER = "mealie";
        POSTGRES_SERVER = "host.containers.internal";
        POSTGRES_PORT = toString globals.ports.postgres;
        POSTGRES_DB = "mealie";
        OIDC_AUTH_ENABLED = "true";
        OIDC_SIGNUP_ENABLED = "true";
        ALLOW_PASSWORD_LOGIN = "false";
        OIDC_CONFIGURATION_URL = "https://auth.${globals.domain}/.well-known/openid-configuration";
        OIDC_CLIENT_ID = "mealie";
        OIDC_AUTO_REDIRECT = "false";
        OIDC_ADMIN_GROUP = "mealie-admins";
        OIDC_USER_GROUP = "mealie-users";
      };
      environmentFiles = [ config.sops.secrets."services/mealie/env".path ];
      extraOptions = [
        "--memory=768m"
        "--pids-limit=64"
      ];
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "mealie.${globals.domain}";
        policy = "one_factor";
        # subject = "group:paperless";
      }
    ];

    identity_providers.oidc.cors.allowed_origins = [
      "https://mealie.${globals.domain}"
    ];

  };

  systemd.services."podman-mealie" = {
    after = [
      "postgresql.service"
    ];
    requires = [
      "postgresql.service"
    ];
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @mealie host mealie.${globals.domain}
    handle @mealie {
      reverse_proxy 127.0.0.1:${toString globals.ports.mealie}
    }
  '';
}
