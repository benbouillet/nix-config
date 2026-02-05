{
  pkgs,
  lib,
  config,
  globals,
  ...
}:
{
  sops.secrets."services/nextcloud/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.paths.nextcloud} 2770 ${globals.users.nextcloud.name} ${globals.groups.nextcloud.name} - -"
    "d ${globals.paths.containersVolumes}/nextcloud/custom_apps 2770 ${globals.users.nextcloud.name} ${globals.groups.nextcloud.name} - -"
    "d ${globals.paths.containersVolumes}/nextcloud/config 2770 ${globals.users.nextcloud.name} ${globals.groups.nextcloud.name} - -"
    "d ${globals.paths.containersVolumes}/nextcloud/themes 2770 ${globals.users.nextcloud.name} ${globals.groups.nextcloud.name} - -"
  ];

  users.users."${globals.users.nextcloud.name}" = {
    isSystemUser = true;
    createHome = false;
    uid = globals.users.nextcloud.UID;
    group = globals.groups.containers.name;
  };

  users.groups = {
    ${globals.groups.nextcloud.name} = {
      gid = globals.groups.nextcloud.GID;
    };
  };

  services = {
    postgresql = {
      enable = lib.mkForce true;
      ensureDatabases = lib.mkAfter [
        "nextcloud"
      ];
      ensureUsers = lib.mkAfter [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
          ensureClauses = {
            createrole = true;
            createdb = true;
            login = true;
            connection_limit = 20;
            password = "SCRAM-SHA-256$4096:Me7MuqjYdj9eLN2IsRSA1w==$UHWzeV3Y/Y+c5F9Btg9tnFVYDXwjtOG7oO4Wr9/i8o8=:x7oqavjtig1/LR0DEda2HlCP2JK+oSnWuWP9jTq7gTk=";
          };
        }
      ];
    };
  };

  virtualisation.oci-containers.containers = {
    "nextcloud" = {
      image = "docker.io/nextcloud:32.0.5";
      ports = [
        "127.0.0.1:${toString globals.ports.nextcloud}:80"
      ];
      volumes = [
        "${globals.paths.nextcloud}:/var/www/html/data:rw"
        "${globals.paths.containersVolumes}/nextcloud/custom_apps:/var/www/html/custom_apps:rw"
        "${globals.paths.containersVolumes}/nextcloud/config:/var/www/html/config:rw"
        "${globals.paths.containersVolumes}/nextcloud/themes:/var/www/html/themes:rw"
      ];
      environment = {
        PUID = toString globals.users.nextcloud.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Etc/UTC";
        POSTGRES_HOST = "host.containers.internal";
        POSTGRES_DB = "nextcloud";
        POSTGRES_USER = "nextcloud";
        # NEXTCLOUD_ADMIN_USER = "admin";
        NEXTCLOUD_DATA_DIR = "/var/www/html/data";
        NEXTCLOUD_TRUSTED_DOMAINS = "nextcloud.${globals.domain}";
        NEXTCLOUD_UPDATE = "0";
        REDIS_HOST = "host.containers.internal";
        REDIS_HOST_PORT = toString globals.ports.redis;
        SMTP_HOST = "smtp.protonmail.ch";
        SMTP_SECURE = "tls";
        SMTP_PORT = "587";
        SMTP_AUTHTYPE = "LOGIN";
        SMTP_NAME = "admin@${globals.domain}";
        MAIL_FROM_ADDRESS = "Raclette Admin <admin@r4clette.com>";
        MAIL_DOMAIN = globals.domain;
      };
      environmentFiles = [ config.sops.secrets."services/nextcloud/env".path ];
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "nextcloud.${globals.domain}";
        policy = "one_factor";
        subject = "group:nextcloud";
      }
    ];

    identity_providers.oidc.cors.allowed_origins = [
      "https://nextcloud.${globals.domain}"
    ];

    identity_providers.oidc = {
      clients = [
        {
          client_id = "nextcloud";
          client_name = "Nextcloud";
          client_secret = "$pbkdf2-sha512$310000$hoA0vwE.03jZt7l7b4GNwQ$Oc2LJ3yzFiktYBv.sbKznvLBRmhJUctJkROLV7hPi3K4JmAZnOA/0u9RaH6I6C4u4CueGp3kHAi3X3NhwKV93Q";
          public = false;
          authorization_policy = "one_factor";
          require_pkce = true;
          pkce_challenge_method = "S256";
          consent_mode = "implicit";
          redirect_uris = [
            "https://nextcloud.${globals.domain}/accounts/oidc/authelia/login/callback/"
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

  systemd.services."podman-nextcloud" = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    wants = [ "nextcloud-oidc-setup.service" ];
  };

  systemd.services."nextcloud-oidc-setup" = {
    description = "Setup Nextcloud OIDC Login app";
    after = [ "podman-nextcloud.service" ];
    wants = [ "podman-nextcloud.service" ];
    wantedBy = [ "multi-user.target" ];

    path = [ "/run/current-system/sw" ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
    };

    script = ''
      set -euo pipefail

      # ${pkgs.podman}/bin/podman exec nextcloud php occ app:install user_oidc || true

      echo "Waiting for Nextcloud to be ready..."
      for i in {1..30}; do
        if ${pkgs.podman}/bin/podman exec nextcloud php occ status || true 2>/dev/null | grep -q "installed: true"; then
          echo "Nextcloud is ready!"
          break
        fi
        sleep 2
      done
    '';
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @nextcloud host nextcloud.${globals.domain}
    handle @nextcloud {
      reverse_proxy 127.0.0.1:${toString globals.ports.nextcloud}
    }
  '';
}
