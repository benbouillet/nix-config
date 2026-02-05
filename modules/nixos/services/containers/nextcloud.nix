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

  # Note: official Nextcloud docker image is using UID 33 & GID 33
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.paths.nextcloud} 2770 33 33 - -"
    "d ${globals.paths.containersVolumes}/nextcloud/custom_apps 2770 33 33 - -"
    "d ${globals.paths.containersVolumes}/nextcloud/config 2770 33 33 - -"
    "d ${globals.paths.containersVolumes}/nextcloud/themes 2770 33 33 - -"
  ];

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
        TZ = "Etc/UTC";
        POSTGRES_HOST = "host.containers.internal";
        POSTGRES_DB = "nextcloud";
        POSTGRES_USER = "nextcloud";
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
        OVERWRITEHOST = "nextcloud.${globals.domain}";
        OVERWRITEPROTOCOL = "https";
        TRUSTED_PROXIES = "${globals.podmanBridgeCIDR} 127.0.0.1";
        APACHE_DISABLE_REWRITE_IP = "1";
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
            "https://nextcloud.${globals.domain}/index.php/apps/user_oidc/code"
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
          token_endpoint_auth_method = "client_secret_post";
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
      EnvironmentFile = config.sops.secrets."services/nextcloud/env".path;
    };

    script = ''
      set -euo pipefail

      # Basic sanity check so we fail loud if the secret is missing
      if [ -z "''${NEXTCLOUD_OIDC_CLIENT_SECRET-}" ]; then
        echo "ERROR: NEXTCLOUD_OIDC_CLIENT_SECRET not set in services/nextcloud/env"
        exit 1
      fi

      OIDC_CLIENT_ID="nextcloud"
      OIDC_PROVIDER_ID="Authelia"
      DISCOVERY_URL="https://auth.${globals.domain}/.well-known/openid-configuration"

      echo "Waiting for Nextcloud to be ready..."
      for i in {1..30}; do
        if ${pkgs.podman}/bin/podman exec nextcloud php occ status || true 2>/dev/null | grep -q "installed: true"; then
          echo "Nextcloud is ready!"
          break
        fi
        sleep 2
      done

      # If after 30 tries it's still not installed, bail out; no point configuring OIDC.
      if ! ${pkgs.podman}/bin/podman exec nextcloud php occ status 2>/dev/null | grep -q "installed: true"; then
        echo "Nextcloud is not installed yet, skipping OIDC setup."
        exit 0
      fi

      # Allow Nextcloud to talk to Authelia's (local) IP
      ${pkgs.podman}/bin/podman exec nextcloud php occ config:system:set allow_local_remote_servers --type=bool --value=true

      echo "Installing and enabling user_oidc…"
      ${pkgs.podman}/bin/podman exec nextcloud php occ app:install user_oidc || true
      ${pkgs.podman}/bin/podman exec nextcloud php occ app:enable user_oidc || true

      echo "Configuring user_oidc provider OIDC_PROVIDER_ID for Authelia…"
      # This will create the provider if it doesn't exist, or update it if it does.
      ${pkgs.podman}/bin/podman exec nextcloud php occ \
        user_oidc:provider "''${OIDC_PROVIDER_ID}" \
          --clientid="''${OIDC_CLIENT_ID}" \
          --clientsecret="''${NEXTCLOUD_OIDC_CLIENT_SECRET}" \
          --discoveryuri="''${DISCOVERY_URL}" \
          --scope="openid profile email groups" \
          --mapping-uid="sub" \
          --mapping-display-name="name" \
          --mapping-email="email" \
          --mapping-groups="groups" \
          --unique-uid="true" \
          --group-provisioning="true" \
          --group-whitelist-regex="^(nextcloud-users|nextcloud-admins)\$" \
          --group-restrict-login-to-whitelist="true"

      # Default token endpoint auth method for the user_oidc app
      ${pkgs.podman}/bin/podman exec nextcloud php occ \
        config:system:set user_oidc default_token_endpoint_auth_method \
          --type=string --value="client_secret_post"

      # Making sure auto-provisioning is explicitly enabled
      ${pkgs.podman}/bin/podman exec nextcloud php occ \
        config:system:set user_oidc auto_provision --type=boolean --value="true" || true

      ${pkgs.podman}/bin/podman exec nextcloud php occ \
        config:system:set user_oidc soft_auto_provision --type=boolean --value="true" || true

      # Deactivates OIDC first login. Set back to `1` if Authelia authentication is broken
      ${pkgs.podman}/bin/podman exec nextcloud php occ \
        config:app:set user_oidc allow_multiple_user_backends --value="0" || true

      # Optional: pre-create groups that come from LLDAP/Authelia.
      # If your LLDAP groups are `nextcloud-users` and `nextcloud-admins`,
      # having them exist in NC means user_oidc can just drop people into them.
      ${pkgs.podman}/bin/podman exec nextcloud php occ group:add nextcloud-users 2>/dev/null || true
      ${pkgs.podman}/bin/podman exec nextcloud php occ group:add nextcloud-admins 2>/dev/null || true

      echo "Nextcloud OIDC setup finished."
    '';
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @nextcloud host nextcloud.${globals.domain}
    handle @nextcloud {
      reverse_proxy 127.0.0.1:${toString globals.ports.nextcloud}
    }
  '';
}
