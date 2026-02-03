{
  lib,
  config,
  globals,
  ...
}:
{
  sops.secrets."authelia/identityValidationJwtSecret" = {
    owner = globals.users.authelia.name;
    group = globals.groups.authentication.name;
    mode = "0400";
  };
  sops.secrets."authelia/sessionSecret" = {
    owner = globals.users.authelia.name;
    group = globals.groups.authentication.name;
    mode = "0400";
  };
  sops.secrets."authelia/storageEncryptionKey" = {
    owner = globals.users.authelia.name;
    group = globals.groups.authentication.name;
    mode = "0400";
  };
  sops.secrets."authelia/smtpPassword" = {
    owner = globals.users.authelia.name;
    group = globals.groups.authentication.name;
    mode = "0400";
  };
  sops.secrets."authelia/oidcIssuerKey" = {
    owner = globals.users.authelia.name;
    group = globals.groups.oidc.name;
    mode = "0440";
  };
  sops.secrets."lldap/env" = {
    owner = globals.users.lldap.name;
    group = globals.groups.authentication.name;
    mode = "0400";
  };
  sops.secrets."lldap/adminPassword" = {
    owner = globals.users.lldap.name;
    group = globals.groups.authentication.name;
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
    "${globals.users.authelia.name}" = {
      isSystemUser = true;
      createHome = false;
      uid = globals.users.authelia.UID;
      group = globals.groups.authentication.name;
    };
    "${globals.users.lldap.name}" = {
      isSystemUser = true;
      createHome = false;
      uid = globals.users.lldap.UID;
      group = globals.groups.authentication.name;
    };
  };
  users.groups = {
    ${globals.groups.authentication.name} = {
      gid = globals.groups.authentication.GID;
    };
    ${globals.groups.oidc.name} = {
      gid = globals.groups.oidc.GID;
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
          name = globals.users.lldap.name;
          ensureDBOwnership = true;
          ensureClauses = {
            createrole = true;
            createdb = true;
            connection_limit = 5;
            password = "SCRAM-SHA-256$4096:hDpTFtNaDMBJKeivoyfkhQ==$zEvVeTD6w9U+GQhxu6BSzu+VFQ0x+ucJn5zkj4KXMOk=:2FXSWeQh+LaC+tQ4A5waU2D3uYE3uoef9oV6I5q4Rt8=";
          };
        }
        {
          name = globals.users.authelia.name;
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
      user = globals.users.authelia.name;
      group = globals.groups.authentication.name;
      settings = {
        server = {
          address = "tcp://127.0.0.1:${toString globals.ports.authelia}";
          disable_healthcheck = false;
        };

        log.level = "info";

        theme = "dark";
        default_2fa_method = "totp";

        session = {
          name = "authelia_session";
          same_site = "lax";
          expiration = "2h";
          inactivity = "10m";
          remember_me = "7d";

          cookies = [
            {
              domain = globals.domain;
              authelia_url = "https://auth.${globals.domain}";
            }
          ];

          redis = {
            host = "127.0.0.1";
            port = globals.ports.redis;
          };
        };

        storage = {
          postgres = {
            address = "unix:///run/postgresql/.s.PGSQL.${toString globals.ports.postgres}";
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
          address = "ldap://127.0.0.1:${toString globals.ports.lldapLdap}";
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
        ldap_user_email = "admin@${globals.domain}";

        ldap_user_pass_file = config.sops.secrets."lldap/adminPassword".path;

        force_ldap_user_pass_reset = "always";

        ldap_host = "127.0.0.1";
        ldap_port = 3890;

        http_host = "127.0.0.1";
        http_port = 17170;

        http_url = "https://id.${globals.domain}";
      };
    };
  };

  services.caddy.virtualHosts = {
    "auth.${globals.domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString globals.ports.authelia}
    '';

    "id.${globals.domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString globals.ports.lldapWebUi}
    '';
  };
}
