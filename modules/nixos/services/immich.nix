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
    host = "${globals.hosts.chewie.ipv4}";
    port = globals.ports.immich;
    mediaLocation = globals.zfs.data.immich.mountPoint;
    accelerationDevices = [ "/dev/dri/by-path/pci-0000:01:00.0-render" ];
    machine-learning.enable = false;
    database = {
      enable = false;
      host = "127.0.0.1";
      port = globals.ports.postgres;
      user = "immich";
      name = "immich";
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

  };

  
}
