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
    "d ${globals.paths.containersVolumes}/paperless/data 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.paths.containersVolumes}/paperless/consume 2770 root ${globals.groups.containers.name} - -"
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
            password = "SCRAM-SHA-256$4096:M6YtjqWKNeTrSCVXXewD7A==$XNRpDmnRKbCBspkorVuajSpn7Lu8TzRb6LpxHO4+Ijw=:nL5ZuCPBrD/mZFMS/YNbIHwGbukEDKWExm87jOJu0Jk=";
          };
        }
      ];
    };
  };

  virtualisation.oci-containers.containers = {
    "paperless" = {
      image = "ghcr.io/paperless-ngx/paperless-ngx:2.20.9";
      ports = [
        "127.0.0.1:${toString globals.ports.paperless}:8000"
      ];
      volumes = [
        "${globals.paths.containersVolumes}/paperless/data:/usr/src/paperless/data:rw"
        "${globals.zfs.data.paperless.mountPoint}:/usr/src/paperless/media:rw"
        "${globals.paths.containersVolumes}/paperless/consume:/usr/src/paperless/consume:rw"
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

    identity_providers.oidc.cors.allowed_origins = [
      "https://docs.${globals.domain}"
    ];

    identity_providers.oidc = {
      clients = [
        {
          client_id = "paperless";
          client_name = "Paperless";
          client_secret = "$pbkdf2-sha512$310000$LmAh1GHHBUT.oSgH4d.cOg$bEDLq/7Jn16L1MuAuJNvZ.mmV2H8DGub8IeydrGfwFUN7dvG7EQUukPHZA5ro50ONiEAFEVif9KOqc8FZ3u0CA";
          public = false;
          authorization_policy = "one_factor";
          require_pkce = true;
          pkce_challenge_method = "S256";
          consent_mode = "implicit";
          redirect_uris = [
            "https://docs.${globals.domain}/accounts/oidc/authelia/login/callback/"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          response_types = [ "code" ];
          grant_types = [
            "authorization_code"
          ];
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_basic";
        }
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

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @docs host docs.${globals.domain}
    handle @docs {
      reverse_proxy 127.0.0.1:${toString globals.ports.paperless}
    }
  '';
}
