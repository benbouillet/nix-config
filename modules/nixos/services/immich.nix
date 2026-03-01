{
  globals,
  config,
  lib,
  ...
}:
{
  sops.secrets."immich/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };
  sops.secrets."immich/oidc_secret" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  services.postgresql = {
    enable = lib.mkForce true;
    ensureDatabases = lib.mkAfter [
      "immich"
    ];
    ensureUsers = lib.mkAfter [
      {
        name = "immich";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
          connection_limit = 20;
          password = "SCRAM-SHA-256$4096:g+/4rpVJ32ZsfNpL6CngtA==$SaD88N7LAPYhWVjRrh2h5ERyD1o2OT3DDdus/wAE6+c=:XRISloNwAn0r2YQ3YDxcVpU4T/hNRmORHJE0AKfh1r0=";
        };
      }
    ];
  };

  systemd.services."immich-server" = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = globals.ports.immich;
    mediaLocation = globals.zfs.data.immich.mountPoint;
    accelerationDevices = [ "/dev/dri/by-path/pci-0000:01:00.0-render" ];
    database = {
      enable = false;
      host = "127.0.0.1";
      port = globals.ports.postgres;
      user = "immich";
      name = "immich";
      enableVectors = false;
    };
    redis = {
      enable = false;
      host = "127.0.0.1";
      port = globals.ports.redis;
    };
    settings = {
      server.externalDomain = "https://images.${globals.domain}";
      oauth = {
        enabled = true;
        issuerUrl = "https://auth.${globals.domain}/.well-known/openid-configuration";
        clientId = "immich";
        clientSecret._secret = config.sops.secrets."immich/oidc_secret".path;
        scope = "openid email profile";
        buttonText = "Login with Authelia";
        autoRegister = true;
        autoLaunch = true;
      };
    };
    secretsFile = config.sops.secrets."immich/env".path;
    environment = {
      DB_HOST = "127.0.0.1";
      DB_PORT = toString globals.ports.postgres;
      DB_USERNAME = "immich";
      DB_DATABASE_NAME = "immich";
      DB_STORAGE_TYPE = "SSD";

      IMMICH_LOG_LEVEL = "error";
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control = {
      rules = [
        {
          domain = "images.${globals.domain}";
          policy = "one_factor";
          subject = "group:immich";
        }
      ];
    };

    identity_providers.oidc.cors.allowed_origins = [
      "https://images.${globals.domain}"
    ];

    identity_providers.oidc.clients = [
      {
        client_id = "immich";
        client_name = "Immich";
        client_secret = "$pbkdf2-sha512$310000$yPx.gTNg3InhYZt0UFH0ug$XPJl5CMyF4MuLipYeQzB2CLG4gf8iOeRHPieb9AOVKWuGe2wFdNbhF/hRkn/GXpOv4GjCl2Bts6im9g7M4d1Nw";
        public = false;
        authorization_policy = "one_factor";
        require_pkce = false;
        pkce_challenge_method = "";
        redirect_uris = [
          "https://images.${globals.domain}/auth/login"
          "https://images.${globals.domain}/user-settings"
          "app.immich:///oauth-callback"
        ];
        scopes = [
          "openid"
          "profile"
          "email"
        ];
        response_types = [ "code" ];
        grant_types = [
          "authorization_code"
        ];
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_post";
      }
    ];
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @images host images.${globals.domain}

    # API + machine endpoints: NO forward_auth (mobile needs these)
    @immich_api {
      host images.${globals.domain}
      path /api/* /.well-known/immich
    }

    handle @immich_api {
      reverse_proxy 127.0.0.1:${toString globals.ports.immich}
    }

    # Everything else (web UI): protect with Authelia
    handle @images {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString globals.ports.immich}
    }
  '';
}
