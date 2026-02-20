{
  globals,
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets."services/seafile/env" = {
    mode = "0400";
    owner = globals.users.seafile.name;
    group = globals.groups.seafile.name;
  };

  users.users = {
    "${globals.users.seafile.name}" = {
      isSystemUser = true;
      createHome = lib.mkForce false;
      uid = globals.users.seafile.UID;
      group = globals.groups.seafile.name;
    };
  };

  users.groups = {
    ${globals.groups.seafile.name} = {
      gid = globals.groups.seafile.GID;
    };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "seafile" ];
    settings = {
      mysqld.bind-address = "0.0.0.0";
    };
  };

  systemd.services."seafile-mysql-bootstrap" = {
    description = "Define MySQL resources for seafile";
    requires = [ "mysql.service" ];
    after = [ "mysql.service" ];
    before = [ "podman-seafile.service" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.mariadb ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      EnvironmentFile = config.sops.secrets."services/seafile/env".path;
    };

    script = ''
      mariadb <<SQL
        CREATE USER IF NOT EXISTS 'seafile'@'%' IDENTIFIED BY "$SEAFILE_MYSQL_DB_PASSWORD";
        CREATE USER IF NOT EXISTS 'seafile'@'localhost' IDENTIFIED BY "$SEAFILE_MYSQL_DB_PASSWORD";

        ALTER USER 'seafile'@'%'        IDENTIFIED BY "$SEAFILE_MYSQL_DB_PASSWORD";
        ALTER USER 'seafile'@'localhost'        IDENTIFIED BY "$SEAFILE_MYSQL_DB_PASSWORD";

        GRANT ALL PRIVILEGES ON seafile.* TO 'seafile'@'%';
        GRANT ALL PRIVILEGES ON seafile.* TO 'seafile'@'localhost';
        FLUSH PRIVILEGES;
      SQL
    '';
  };

  # systemd.services."podman-seafile" = {
  #   after = [
  #     "mysql.service"
  #     "redis-raclette.service"
  #   ];
  #   requires = [
  #     "mysql.service"
  #     "redis-raclette.service"
  #   ];
  # };

  # virtualisation.oci-containers.containers.seafile = {
  #   image = "seafileltd/seafile-mc:13.0.18";
  #   autoStart = true;
  #   # volumes = [
  #   #   "/srv/seafile/data:/shared"
  #   # ];
  #   ports = [ "127.0.0.1:${toString globals.ports.seafile}:80" ];
  #   extraOptions = [
  #     "--health-cmd=curl -sf -H 'Host: seafile.${globals.domain}' http://localhost/ || exit 1"
  #     "--health-interval=30s"
  #     "--health-timeout=10s"
  #     "--health-retries=5"
  #     "--health-start-period=120s"
  #   ];
  #   # environmentFiles = [ "/var/lib/seafile/seafile.env" ];
  #   environment = {
  #     SEAFILE_SERVER_HOSTNAME = "seafile.${globals.domain}";
  #     SEAFILE_SERVER_PROTOCOL = "https";
  #     FORCE_HTTPS_IN_CONF = true;
  #     TIME_ZONE = "Etc/UTC";
  #     SITE_ROOT = "/";
  #     NON_ROOT = "false";
  #     SEAFILE_LOG_TO_STDOUT = true;
  #
  #     # Admin Configuration (only used on first setup)
  #     INIT_SEAFILE_ADMIN_EMAIL = "benbouillet@pm.me";
  #     INIT_SEAFILE_ADMIN_PASSWORD = "foobarbfoo";
  #
  #     # MySQL/MariaDB Configuration
  #     SEAFILE_MYSQL_DB_HOST = "seafile-db";
  #     SEAFILE_MYSQL_DB_PORT = "3306";
  #     SEAFILE_MYSQL_DB_USER = "seafile";
  #     SEAFILE_MYSQL_DB_PASSWORD = "$DB_PASSWORD";
  #     INIT_SEAFILE_MYSQL_ROOT_PASSWORD = "$DB_PASSWORD";
  #     SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
  #     SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
  #     SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seahub_db";
  #
  #     # JWT Configuration
  #     JWT_PRIVATE_KEY = "$JWT_KEY";
  #
  #     # Cache Configuration (Redis)
  #     CACHE_PROVIDER = "redis";
  #     REDIS_HOST = "seafile-redis";
  #     REDIS_PORT = "6379";
  #     REDIS_PASSWORD = "";
  #
  #     # Notification Server
  #     ENABLE_NOTIFICATION_SERVER = "true";
  #     INNER_NOTIFICATION_SERVER_URL = "http://notification-server:8083";
  #     NOTIFICATION_SERVER_URL = "https://${domain}/notification";
  #
  #     # SeaDoc Configuration (disabled - not running seadoc container)
  #     ENABLE_SEADOC = "false";
  #
  #     # Seafile AI (disabled)
  #     ENABLE_SEAFILE_AI = "false";
  #
  #     # Limits
  #     MD_FILE_COUNT_LIMIT = "100000";
  #   };
  # };
}
#       DB_PASSWORD=$(cat ${config.age.secrets.seafile-db-password.path})
#       ADMIN_PASSWORD=$(cat ${config.age.secrets.seafile-admin-password.path})
#       JWT_KEY=$(cat ${config.age.secrets.seafile-jwt-key.path})
#
#       # Seafile env file (v13.0 format - matches official compose)
#       cat > /var/lib/seafile/seafile.env << EOF
#       # Server Configuration
#       EOF
#
#
#       mkdir -p /srv/seafile/data/seafile/conf
#       cat > /srv/seafile/data/seafile/conf/seahub_settings.py << EOF
#       # Custom settings for reverse proxy.
#       # Keep these explicitly pinned so markdown/file APIs resolve to the public URL.
#       SERVICE_URL = "https://${domain}"
#       FILE_SERVER_ROOT = "https://${domain}/seafhttp"
#       ENABLE_SETTINGS_VIA_WEB = False
#       # Keep host validation permissive behind Traefik to avoid internal host mismatch
#       # during Seafile permission checks on /seafhttp requests.
#       ALLOWED_HOSTS = ['*']
#       USE_X_FORWARDED_HOST = True
#       SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
#       CSRF_COOKIE_SECURE = True
#       CSRF_COOKIE_SAMESITE = 'Strict'
#       CSRF_TRUSTED_ORIGINS = ['https://${domain}']
#       EOF
#       chmod 644 /srv/seafile/data/seafile/conf/seahub_settings.py
#
#     '';
#
#   }
#   (mylib.dockerHelpers.mkDockerNetwork {
#     inherit config;
#     name = "seafile";
#     networkName = "seafile-net";
#   })
#   (mylib.dockerHelpers.mkContainerNetworkDeps {
#     name = "seafile";
#     containers = ["seafile-db" "seafile-redis" "seafile"];
#   })
#   {
#     services.traefik.dynamicConfigOptions.http = mylib.traefikHelpers.mkTraefikRoute {
#       name = "seafile";
#       host = "127.0.0.1";
#       inherit domain port;
#     };
#   }
#   (mylib.dockerHelpers.mkDatabaseDumpService {
#     inherit config pkgs;
#     name = "seafile";
#     description = "Dump Seafile MariaDB database";
#     containerDeps = ["seafile-db"];
#     dumpCommand = ''
#       DB_PASSWORD=$(cat ${config.age.secrets.seafile-db-password.path})
#       ${config.virtualisation.docker.package}/bin/docker exec seafile-db \
#         mariadb-dump -u root -p"$DB_PASSWORD" --all-databases > "$BACKUP_DIR/seafile.sql.tmp"
#       mv "$BACKUP_DIR/seafile.sql.tmp" "$BACKUP_DIR/seafile.sql"
#     '';
#   })
# ]
