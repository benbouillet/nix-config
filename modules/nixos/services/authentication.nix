{
  lib,
  config,
  ...
}:
let
  domain = "r4clette.com";
  autheliaUser = {
    name = "authelia";
    UID = 930;
  };
  autheliaGroup = {
    name = "authelia";
    GID = 994;
  };
  ports = {
    postgres = 5432;
    authelia = 9091;
  };
in
{
  sops.secrets."authelia/identityValidationJWTSecret" = {
    owner = autheliaUser.name;
    group = autheliaGroup.name;
    mode = "0400";
  };
  sops.secrets."authelia/sessionSecret" = {
    owner = autheliaUser.name;
    group = autheliaGroup.name;
    mode = "0400";
  };
  sops.secrets."authelia/storageEncryptionKey" = {
    owner = autheliaUser.name;
    group = autheliaGroup.name;
    mode = "0400";
  };
  sops.secrets."authelia/postgresPassword" = {
    owner = autheliaUser.name;
    group = autheliaGroup.name;
    mode = "0400";
  };

  environment.etc."authelia/users.yml".text = ''
    users:
      ben:
        displayname: "Ben"
        password: "$argon2id$v=19$m=65536,t=3,p=4$StQK5euegRUBrlwP8LUL/A$zLSkrFKn7Or6rKHUonVzfagVh2wKLW7knes+jFuLjQI"
        email: "benbouillet@pm.me"
        groups:
          - users
  '';

  users.users."${autheliaUser.name}" = {
    isSystemUser = true;
    createHome = false;
    uid = autheliaUser.UID;
    group = autheliaGroup.name;
  };
  users.groups.${autheliaGroup.name} = {
    gid = autheliaGroup.GID;
  };

  services.postgresql = {
    enable = lib.mkForce true;
    ensureDatabases = lib.mkAfter [
      "authelia"
    ];
    ensureUsers = lib.mkAfter [
      {
        name = "authelia";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
          connection_limit = 5;
          password = "SCRAM-SHA-256$4096:Q0qWO6bX/jc5tU5Yw/i+KA==$bNDhPFOHae8dmADQ0RyQ+mkXRe7cjT6swOxguaJ5wpk=:juVz8wdXAr9uEbtTqYP4zr+H8nRfFsCNpHtmS40HkLc=";
        };
      }
    ];
  };

  services.authelia.instances."raclette" = {
    enable = true;
    user = autheliaUser.name;
    group = autheliaGroup.name;
    settings = {
      server = {
        address = "tcp://127.0.0.1:${toString ports.authelia}";
        disable_healthcheck = false;
      };

      log.level = "info";

      theme = "dark";
      default_2fa_method = "totp";

      session = {
        name = "authelia_session";
        same_site = "lax";
        expiration = "1h";
        inactivity = "5m";

        cookies = [
          {
            domain = domain;
            authelia_url = "https://auth.${domain}";
          }
        ];
      };

      storage = {
        postgres = {
          address = "tcp://127.0.0.1:${toString ports.postgres}";
          database = "authelia";
          schema = "public";
          username = "authelia";
        };
        encryption_key = ""; # again, we’ll use secrets.* for this
      };

      notifier = {
        filesystem = {
          filename = "/tmp/notification.txt";
        };
      };

      authentication_backend.file = {
        path = "/etc/authelia/users.yml";
        password = {
          algorithm = "argon2id";
          iterations = 3;
          key_length = 32;
          salt_length = 16;
          memory = 65536;
          parallelism = 4;
        };
      };

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = "debug.${domain}";
            policy = "one_factor";
            subject = "group:users";
          }
        ];
      };

      # identity_providers.oidc = {
      #   enable = true;
      # };
    };

    environmentVariables = {
      AUTHELIA_STORAGE_POSTGRES_PASSWORD_FILE = config.sops.secrets."authelia/postgresPassword".path;
    };

    secrets = {
      jwtSecretFile = config.sops.secrets."authelia/identityValidationJWTSecret".path;
      sessionSecretFile = config.sops.secrets."authelia/sessionSecret".path;
      storageEncryptionKeyFile = config.sops.secrets."authelia/storageEncryptionKey".path;
    };
  };

  services.caddy.virtualHosts."auth.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString ports.authelia}
  '';
}
