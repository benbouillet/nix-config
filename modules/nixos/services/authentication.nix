{
  lib,
  pkgs,
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
  sops.secrets."authelia/oidcClientSecretImmich" = {
    owner = globals.users.authelia.name;
    mode = "0400";
  };
  sops.secrets."authelia/oidcClientSecretMealie" = {
    owner = globals.users.authelia.name;
    mode = "0400";
  };
  sops.secrets."authelia/oidcClientSecretPaperless" = {
    owner = globals.users.authelia.name;
    mode = "0400";
  };

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
          };
        }
        {
          name = globals.users.authelia.name;
          ensureDBOwnership = true;
          ensureClauses = {
            createrole = true;
            createdb = true;
            connection_limit = 5;
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

      settingsFiles = [
        (pkgs.writeText "oidc-clients.yml" ''
          identity_providers:
            oidc:
              clients:
                - client_id: 'immich'
                  client_name: 'Immich'
                  client_secret: {{ secret "${config.sops.secrets."authelia/oidcClientSecretImmich".path}" }}
                  public: false
                  authorization_policy: 'one_factor'
                  require_pkce: false
                  pkce_challenge_method: ""
                  redirect_uris:
                    - 'https://images.${globals.domain}/auth/login'
                    - 'https://images.${globals.domain}/user-settings'
                    - 'app.immich:///oauth-callback'
                  scopes: ['openid', 'profile', 'email']
                  response_types: ['code']
                  grant_types: ['authorization_code']
                  access_token_signed_response_alg: 'none'
                  userinfo_signed_response_alg: 'none'
                  token_endpoint_auth_method: 'client_secret_post'
                - client_id: 'mealie'
                  client_name: 'Mealie'
                  client_secret: {{ secret "${config.sops.secrets."authelia/oidcClientSecretMealie".path}" }}
                  public: false
                  authorization_policy: 'one_factor'
                  require_pkce: true
                  pkce_challenge_method: 'S256'
                  redirect_uris:
                    - 'https://mealie.${globals.domain}/login'
                  scopes: ['openid', 'email', 'profile', 'groups']
                  response_types: ['code']
                  grant_types: ['authorization_code']
                  access_token_signed_response_alg: 'none'
                  userinfo_signed_response_alg: 'none'
                  token_endpoint_auth_method: 'client_secret_basic'
                - client_id: 'paperless'
                  client_name: 'Paperless'
                  client_secret: {{ secret "${config.sops.secrets."authelia/oidcClientSecretPaperless".path}" }}
                  public: false
                  authorization_policy: 'one_factor'
                  require_pkce: true
                  pkce_challenge_method: 'S256'
                  consent_mode: 'implicit'
                  redirect_uris:
                    - 'https://docs.${globals.domain}/accounts/oidc/authelia/login/callback/'
                  scopes: ['openid', 'profile', 'email', 'groups']
                  response_types: ['code']
                  grant_types: ['authorization_code']
                  access_token_signed_response_alg: 'none'
                  userinfo_signed_response_alg: 'none'
                  token_endpoint_auth_method: 'client_secret_basic'
        '')
      ];
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
