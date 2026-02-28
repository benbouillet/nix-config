{
  globals,
  config,
  lib,
  ...
}:
{
  sops.secrets."vaultwarden/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  services.postgresql = {
    enable = lib.mkForce true;
    ensureDatabases = lib.mkAfter [
      "vaultwarden"
    ];
    ensureUsers = lib.mkAfter [
      {
        name = "vaultwarden";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
          connection_limit = 20;
          password = "SCRAM-SHA-256$4096:9eDc5jPSOR/GGiqwDn9oVg==$h64D93+wBWXwF+tLiEz8cq9cXrvQvbZ8Kuf7ms9bSKY=:JfQacPMggQ1rBpbUZz+dRKZ+f+l1ww2uwDe9Uv6zXhM=";
        };
      }
    ];
  };

  systemd.services."podman-vaultwarden" = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  services.vaultwarden = {
    enable = true;
    domain = "vault.${globals.domain}";
    dbBackend = "postgresql";
    config = {
      SIGNUPS_ALLOWED = true;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = globals.ports.vaultwarden;
      ROCKET_LOG = "error";
      SMTP_HOST = "smtp.protonmail.ch";
      SMTP_FROM = "admin@${globals.domain}";
      SMTP_FROM_NAME = "Raclette Admin";
      SMTP_PORT = "587";
      SMTP_SECURITY = "starttls";
      SMTP_USERNAME = "admin@${globals.domain}";
      SMTP_TIMEOUT = "15";
    };
    environmentFile = config.sops.secrets."vaultwarden/env".path;
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "vault.${globals.domain}";
        policy = "one_factor";
        subject = "group:vaultwarden";
      }
    ];

    identity_providers.oidc.cors.allowed_origins = [
      "https://vault.${globals.domain}"
    ];

    identity_providers.oidc = {
      claims_policies = {
        vaultwarden = {
          id_token = [ "vaultwarden_roles" ];
          custom_claims = {
            vaultwarden_roles = {
              attribute = "groups";
            };
          };
        };
      };
      scopes = {
        vaultwarden = {
          claims = [ "vaultwarden_roles" ];
        };
      };
      clients = [
        {
          client_id = "vaultwarden";
          client_name = "Vaultwarden";
          client_secret = "$pbkdf2-sha512$310000$hvPq8xGMtlfuOUG6Xb0YYg$iMpP85aHlw7kpN2FPdhYepgxyseQe7D4p61r2jfJeNGPmKGeGb5ahviCB6Ihh1kmlMeI0uaylsHmPV9jZt8ICg";
          public = false;
          authorization_policy = "one_factor";
          require_pkce = true;
          pkce_challenge_method = "S256";
          claims_policy = "vaultwarden";
          redirect_uris = [
            "https://vault.${globals.domain}/identity/connect/oidc-signin"
          ];
          scopes = [
            "openid"
            "offline_access"
            "profile"
            "email"
            "vaultwarden"
          ];
          response_types = [ "code" ];
          grant_types = [
            "authorization_code"
            "refresh_token"
          ];
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_basic";
        }
      ];
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @vault host vault.${globals.domain}
    handle @vault {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString globals.ports.vaultwarden}
    }
  '';
}
