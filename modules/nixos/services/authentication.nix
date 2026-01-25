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
            password = "SCRAM-SHA-256$4096:NvD2yIkrFsiGwIE0I8p36A==$rVCm1iVVCZkQIoM7LkbmoTJ+fmDPIUHnLjQo4iCGSR8=:MWu5qzUt0LZ9X4Cv1zARwNJorj+TsV6z0iJfig9Lb0E=";
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
          rules = [
            {
              domain = "debug.${domain}";
              policy = "one_factor";
              subject = "group:debug";
            }
            {
              domain = "nextcloud.${domain}";
              policy = "two_factor";
              subject = "group:nextcloud";
            }
          ];
        };

        definitions.user_attributes.is_nextcloud_admin = {
          expression = ''"nextcloud-admins" in groups'';
        };

        identity_providers.oidc = {
          claims_policies.nextcloud_userinfo.custom_claims.is_nextcloud_admin = {
            attribute = "is_nextcloud_admin";
          };
          scopes.nextcloud_userinfo.claims = [ "is_nextcloud_admin" ];
          clients = [
            {
              client_id = "nextcloud";
              client_name = "Nextcloud";
              client_secret = "$pbkdf2-sha512$310000$eyITXRD6EHqMB0msWEqBNQ$V0D6V57a8NXZKj8HU3wLEjyU/XJJ5JxnFsMisO9vtdGAs.E.MX6z.HQWRl8Ik4c0zAse6MmrVlvLe8TQ53nbQg";
              public = false;

              authorization_policy = "two_factor";

              claims_policy = "nextcloud_userinfo";

              redirect_uris = [
                "https://nextcloud.${domain}/apps/oidc_login/oidc"
              ];

              scopes = [
                "openid"
                "profile"
                "email"
                "groups"
                "nextcloud_userinfo"
              ];
            }
          ];
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

        ldap_host = "127.0.0.1";
        ldap_port = 3890;

        http_host = "127.0.0.1";
        http_port = 17170;

        http_url = "https://id.${domain}";

        environmentFile = config.sops.secrets."lldap/env".path;
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
