{
  pkgs,
  lib,
  config,
  globals,
  ...
}:
let
  # Minimal nginx config for Nextcloud + PHP-FPM
  nextcloudNginxConf = pkgs.writeText "nextcloud-nginx.conf" ''
    upstream php-handler {
        server 127.0.0.1:9000;
    }

    # Set the `immutable` cache control options only for assets with a cache busting `v` argument
    map $arg_v $asset_immutable {
        "" "";
        default ", immutable";
    }

    server {
        127.0.0.1:${globals.ports.nextcloud};
        server_name nextcloud.${globals.domain};

        # Prevent nginx HTTP Server Detection
        server_tokens off;

        # Path to the root of your installation
        root /var/www/nextcloud;

        map $http_x_forwarded_proto $fastcgi_https {
            default "";
            https "on";
        }

        # set max upload size and increase upload timeout:
        client_max_body_size 512M;
        client_body_timeout 300s;
        fastcgi_buffers 64 4K;

        # Proxy and client response timeouts
        # Uncomment an increase these if facing timeout errors during large file uploads
        #proxy_connect_timeout 60s;
        #proxy_send_timeout 60s;
        #proxy_read_timeout 60s;
        #send_timeout 60s;

        # Enable gzip but do not remove ETag headers
        gzip on;
        gzip_vary on;
        gzip_comp_level 4;
        gzip_min_length 256;
        gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
        gzip_types application/atom+xml text/javascript application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/wasm application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

        # Pagespeed is not supported by Nextcloud, so if your server is built
        # with the `ngx_pagespeed` module, uncomment this line to disable it.
        #pagespeed off;

        # The settings allows you to optimize the HTTP2 bandwidth.
        # See https://blog.cloudflare.com/delivering-http-2-upload-speed-improvements/
        # for tuning hints
        client_body_buffer_size 512k;

        # HTTP response headers borrowed from Nextcloud `.htaccess`
        add_header Referrer-Policy                   "no-referrer"       always;
        add_header X-Content-Type-Options            "nosniff"           always;
        add_header X-Frame-Options                   "SAMEORIGIN"        always;
        add_header X-Permitted-Cross-Domain-Policies "none"              always;
        add_header X-Robots-Tag                      "noindex, nofollow" always;

        # Remove X-Powered-By, which is an information leak
        fastcgi_hide_header X-Powered-By;

        # Set .mjs and .wasm MIME types
        # Either include it in the default mime.types list
        # and include that list explicitly or add the file extension
        # only for Nextcloud like below:
        include mime.types;
        types {
            text/javascript mjs;
      application/wasm wasm;
        }

        # Specify how to handle directories -- specifying `/index.php$request_uri`
        # here as the fallback means that Nginx always exhibits the desired behaviour
        # when a client requests a path that corresponds to a directory that exists
        # on the server. In particular, if that directory contains an index.php file,
        # that file is correctly served; if it doesn't, then the request is passed to
        # the front-end controller. This consistent behaviour means that we don't need
        # to specify custom rules for certain paths (e.g. images and other assets,
        # `/updater`, `/ocs-provider`), and thus
        # `try_files $uri $uri/ /index.php$request_uri`
        # always provides the desired behaviour.
        index index.php index.html /index.php$request_uri;

        # Rule borrowed from `.htaccess` to handle Microsoft DAV clients
        location = / {
            if ( $http_user_agent ~ ^DavClnt ) {
                return 302 /remote.php/webdav/$is_args$args;
            }
        }

        location = /robots.txt {
            allow all;
            log_not_found off;
            access_log off;
        }

        # Make a regex exception for `/.well-known` so that clients can still
        # access it despite the existence of the regex rule
        # `location ~ /(\.|autotest|...)` which would otherwise handle requests
        # for `/.well-known`.
        location ^~ /.well-known {
            # The rules in this block are an adaptation of the rules
            # in `.htaccess` that concern `/.well-known`.

            location = /.well-known/carddav { return 301 /remote.php/dav/; }
            location = /.well-known/caldav  { return 301 /remote.php/dav/; }

            location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
            location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

            # Let Nextcloud's API for `/.well-known` URIs handle all other
            # requests by passing them to the front-end controller.
            return 301 /index.php$request_uri;
        }

        # Rules borrowed from `.htaccess` to hide certain paths from clients
        location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
        location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

        # Ensure this block, which passes PHP files to the PHP process, is above the blocks
        # which handle static assets (as seen below). If this block is not declared first,
        # then Nginx will encounter an infinite rewriting loop when it prepends `/index.php`
        # to the URI, resulting in a HTTP 500 error response.
        location ~ \.php(?:$|/) {
            # Required for legacy support
            rewrite ^/(?!index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|ocs-provider\/.+|.+\/richdocumentscode(_arm64)?\/proxy) /index.php$request_uri;

            fastcgi_split_path_info ^(.+?\.php)(/.*)$;
            set $path_info $fastcgi_path_info;

            try_files $fastcgi_script_name =404;

            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $path_info;
            fastcgi_param HTTPS $fastcgi_https;

            fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice
            fastcgi_param front_controller_active true;     # Enable pretty urls
            fastcgi_pass php-handler;

            fastcgi_intercept_errors on;
            fastcgi_request_buffering on;                   # Required as PHP-FPM does not support chunked transfer encoding and requires a valid ContentLength header.

            # PHP-FPM 504 response timeouts
            # Uncomment and increase these if facing timeout errors during large file uploads
            #fastcgi_read_timeout 60s;
            #fastcgi_send_timeout 60s;
            #fastcgi_connect_timeout 60s;

            fastcgi_max_temp_file_size 0;
        }

        # Serve static files
        location ~ \.(?:css|js|mjs|svg|gif|ico|jpg|png|webp|wasm|tflite|map|ogg|flac|mp4|webm)$ {
            try_files $uri /index.php$request_uri;
            # HTTP response headers borrowed from Nextcloud `.htaccess`
            add_header Cache-Control                     "public, max-age=15778463$asset_immutable";
            add_header Referrer-Policy                   "no-referrer"       always;
            add_header X-Content-Type-Options            "nosniff"           always;
            add_header X-Frame-Options                   "SAMEORIGIN"        always;
            add_header X-Permitted-Cross-Domain-Policies "none"              always;
            add_header X-Robots-Tag                      "noindex, nofollow" always;
            access_log off;     # Optional: Don't log access to assets
        }

        location ~ \.(otf|woff2?)$ {
            try_files $uri /index.php$request_uri;
            expires 7d;         # Cache-Control policy borrowed from `.htaccess`
            access_log off;     # Optional: Don't log access to assets
        }

        # Rule borrowed from `.htaccess`
        location /remote {
            return 301 /remote.php$request_uri;
        }

        location / {
            try_files $uri $uri/ /index.php$request_uri;
        }
    }
  '';
in
{
  sops.secrets."services/nextcloud/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  # Note: official Nextcloud docker image is using UID 33 & GID 33
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.paths.nextcloud} 2770 33 33 - -"
    "d ${globals.paths.containersVolumes}/nextcloud 2770 33 33 - -"
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
    "nextcloud-fpm" = {
      image = "docker.io/nextcloud:33.0.0-fpm";
      extraOptions = [
        "--memory=512m"
        "--memory-swap=512m"
        "--pids-limit=256"
      ];
      volumes = [
        "nextcloud-www:/var/www/html:rw"
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
        MAIL_FROM_ADDRESS = "Raclette Admin <admin@${globals.domain}>";
        MAIL_DOMAIN = globals.domain;
        OVERWRITECLIURL = "https://nextcloud.${globals.domain}";
        OVERWRITEHOST = "nextcloud.${globals.domain}";
        OVERWRITEPROTOCOL = "https";
        TRUSTED_PROXIES = "${globals.podmanBridgeCIDR} 127.0.0.1";
      };
      environmentFiles = [ config.sops.secrets."services/nextcloud/env".path ];
    };

    "nextcloud-nginx" = {
      image = "docker.io/nginx:1.29.5-alpine";
      extraOptions = [
        "--memory=128m"
        "--memory-swap=128m"
        "--pids-limit=128"
      ];
      ports = [
        "127.0.0.1:${toString globals.ports.nextcloud}:80"
      ];
      volumes = [
        "nextcloud-www:/var/www/html:ro"
        "${globals.paths.containersVolumes}/nextcloud/custom_apps:/var/www/html/custom_apps:ro"
        "${globals.paths.containersVolumes}/nextcloud/config:/var/www/html/config:ro"
        "${globals.paths.containersVolumes}/nextcloud/themes:/var/www/html/themes:ro"
        "${nextcloudNginxConf}:/etc/nginx/conf.d/default.conf:ro"
      ];

      dependsOn = [ "nextcloud-fpm" ];
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
            "https://nextcloud.${globals.domain}/apps/user_oidc/code"
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

  systemd.services."podman-nextcloud-fpm" = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    wants = [ "nextcloud-oidc-setup.service" ];
  };

  systemd.services."nextcloud-oidc-setup" = {
    description = "Setup Nextcloud OIDC Login app";
    after = [ "podman-nextcloud-fpm.service" ];
    wants = [ "podman-nextcloud-fpm.service" ];
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
