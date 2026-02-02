{
  lib,
  config,
  ...
}:
let
  domain = "r4clette.com";
  users = {
    authelia = {
      name = "authelia";
      UID = 930;
    };
    lldap = {
      name = "lldap";
      UID = 931;
    };
  };
  groups = {
    authentication = {
      name = "authent";
      GID = 930;
    };
    oidc = {
      name = "oidc";
      GID = 931;
    };
  };
  ports = {
    postgres = 5432;
    authelia = 9091;
    lldapWebUi = 17170;
    lldapLdap = 3890;
    redis = 6379;
  };
in
{
  sops.secrets."authelia/identityValidationJwtSecret" = {
    owner = users.authelia.name;
    group = groups.authentication.name;
    mode = "0400";
  };
  sops.secrets."authelia/sessionSecret" = {
    owner = users.authelia.name;
    group = groups.authentication.name;
    mode = "0400";
  };
  sops.secrets."authelia/storageEncryptionKey" = {
    owner = users.authelia.name;
    group = groups.authentication.name;
    mode = "0400";
  };
  sops.secrets."authelia/smtpPassword" = {
    owner = users.authelia.name;
    group = groups.authentication.name;
    mode = "0400";
  };
  sops.secrets."authelia/oidcIssuerKey" = {
    owner = users.authelia.name;
    group = groups.oidc.name;
    mode = "0440";
  };
  sops.secrets."lldap/env" = {
    owner = users.lldap.name;
    group = groups.authentication.name;
    mode = "0400";
  };
  sops.secrets."lldap/adminPassword" = {
    owner = users.lldap.name;
    group = groups.authentication.name;
    mode = "0440";
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

  users.users = {
    "${users.authelia.name}" = {
      isSystemUser = true;
      createHome = false;
      uid = users.authelia.UID;
      group = groups.authentication.name;
    };
    "${users.lldap.name}" = {
      isSystemUser = true;
      createHome = false;
      uid = users.lldap.UID;
      group = groups.authentication.name;
    };
  };
  users.groups = {
    ${groups.authentication.name} = {
      gid = groups.authentication.GID;
    };
    ${groups.oidc.name} = {
      gid = groups.oidc.GID;
    };
  };

  services = {
    postgresql = {
      enable = lib.mkForce true;
      ensureDatabases = lib.mkAfter [
        "authelia"
        "lldap"
      ];
      ensureUsers = lib.mkAfter [
        {
          name = users.lldap.name;
          ensureDBOwnership = true;
          ensureClauses = {
            createrole = true;
            createdb = true;
            connection_limit = 5;
            password = "SCRAM-SHA-256$4096:hDpTFtNaDMBJKeivoyfkhQ==$zEvVeTD6w9U+GQhxu6BSzu+VFQ0x+ucJn5zkj4KXMOk=:2FXSWeQh+LaC+tQ4A5waU2D3uYE3uoef9oV6I5q4Rt8=";
          };
        }
        {
          name = users.authelia.name;
          ensureDBOwnership = true;
          ensureClauses = {
            createrole = true;
            createdb = true;
            connection_limit = 5;
            password = "SCRAM-SHA-256$4096:0VaMc/tMcHS/mb/CPtCW9Q==$UJ9Jjmnr5O+a4JRhqbG3a74ZEpXwMelWNwPXzc1FvUo=:u9pn9psBM1kCoEVhXI8/1Pfpwt8qkss3RQY4q0Awsn8=";
          };
        }
      ];
    };

    authelia.instances."raclette" = {
      enable = true;
      user = users.authelia.name;
      group = groups.authentication.name;
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

          redis = {
            host = "127.0.0.1";
            port = ports.redis;
          };
        };

        storage = {
          postgres = {
            address = "unix:///run/postgresql/.s.PGSQL.${toString ports.postgres}";
            database = "authelia";
            schema = "public";
            username = "authelia";
          };
        };

        notifier = {
          smtp = {
            address = "smtp://smtp.protonmail.ch:587";
            username = "admin@r4clette.com";
            sender = "Raclette Admin <admin@r4clette.com>";
          };
        };

        authentication_backend.ldap = {
          address = "ldap://127.0.0.1:${toString ports.lldapLdap}";
          implementation = "lldap";
          user = "uid=admin,ou=people,dc=r4clette,dc=com";
          base_dn = "dc=r4clette,dc=com";
        };

        access_control = {
          default_policy = "deny";
        };

        identity_providers.oidc = {
          lifespans = {
            access_token = "1h";
            id_token = "1h";
            refresh_token = "720h";
          };
          cors = {
            endpoints = [
              "authorization"
              "token"
              "revocation"
              "introspection"
              "userinfo"
            ];
            allowed_origins_from_client_redirect_uris = true;
          };
        };
      };

      environmentVariables = {
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.sops.secrets."authelia/smtpPassword".path;
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.sops.secrets."lldap/adminPassword".path;
      };

      secrets = {
        jwtSecretFile = config.sops.secrets."authelia/identityValidationJwtSecret".path;
        sessionSecretFile = config.sops.secrets."authelia/sessionSecret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/storageEncryptionKey".path;
        oidcIssuerPrivateKeyFile = config.sops.secrets."authelia/oidcIssuerKey".path;
      };
    };

    lldap = {
      enable = true;
      environmentFile = config.sops.secrets."lldap/env".path;
      silenceForceUserPassResetWarning = true;

      settings = {
        ldap_base_dn = "dc=r4clette,dc=com";
        ldap_user_dn = "admin";
        ldap_user_email = "admin@${domain}";

        ldap_user_pass_file = config.sops.secrets."lldap/adminPassword".path;

        force_ldap_user_pass_reset = "always";

        ldap_host = "127.0.0.1";
        ldap_port = 3890;

        http_host = "127.0.0.1";
        http_port = 17170;

        http_url = "https://id.${domain}";
      };
    };
  };

  services.caddy.virtualHosts = {
    "auth.${domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString ports.authelia}
    '';

    "id.${domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString ports.lldapWebUi}
    '';
  };
}
