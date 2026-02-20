{
  globals,
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets."mysql/env" = {
    mode = "0400";
  };

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
    settings = {
      mysqld.bind-address = "0.0.0.0";
      mysqld.port = globals.ports.mysql;
      mysqld."skip-name-resolve" = true;
    };
  };

  systemd.services."mysql-bootstrap" = {
    description = "Define MySQL bootstrap";
    requires = [ "mysql.service" ];
    after = [ "mysql.service" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.mariadb ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      EnvironmentFile = config.sops.secrets."mysql/env".path;
    };

    script = ''
      mariadb <<SQL
        CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD";
        ALTER USER 'root'@'%' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD";
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
      SQL
    '';
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
        CREATE USER IF NOT EXISTS '${globals.users.seafile.name}'@'%' IDENTIFIED BY "$SEAFILE_MYSQL_DB_PASSWORD";
        CREATE USER IF NOT EXISTS '${globals.users.seafile.name}'@'localhost' IDENTIFIED BY "$SEAFILE_MYSQL_DB_PASSWORD";

        ALTER USER '${globals.users.seafile.name}'@'%' IDENTIFIED BY "$SEAFILE_MYSQL_DB_PASSWORD";
        ALTER USER '${globals.users.seafile.name}'@'localhost' IDENTIFIED BY "$SEAFILE_MYSQL_DB_PASSWORD";

        GRANT ALL PRIVILEGES ON seafile.* TO 'seafile'@'%';
        GRANT ALL PRIVILEGES ON seafile.* TO 'seafile'@'localhost';
        FLUSH PRIVILEGES;
      SQL
    '';
  };

  systemd.services."podman-seafile" = {
    after = [
      "mysql.service"
      "mysql-bootstrap.service"
      "seafile-mysql-bootstrap.service"
      "redis-raclette.service"
    ];
    requires = [
      "mysql.service"
      "mysql-bootstrap.service"
      "seafile-mysql-bootstrap.service"
      "redis-raclette.service"
    ];
  };

  virtualisation.oci-containers.containers.seafile = {
    image = "seafileltd/seafile-mc:13.0.18";
    autoStart = true;
    # volumes = [
    #   "/srv/seafile/data:/shared"
    # ];
    ports = [ "127.0.0.1:${toString globals.ports.seafile}:80" ];
    # extraOptions = [
    #   "--health-cmd=curl -sf -H 'Host: seafile.${globals.domain}' http://localhost/ || exit 1"
    #   "--health-interval=30s"
    #   "--health-timeout=10s"
    #   "--health-retries=5"
    #   "--health-start-period=120s"
    # ];
    environmentFiles = [ config.sops.secrets."services/seafile/env".path ];
    environment = {
      SEAFILE_SERVER_HOSTNAME = "seafile.${globals.domain}";
      SEAFILE_SERVER_PROTOCOL = "http";
      FORCE_HTTPS_IN_CONF = "false";
      TIME_ZONE = "Etc/UTC";
      SITE_ROOT = "/";
      NON_ROOT = "false";
      SEAFILE_LOG_TO_STDOUT = "true";

      # Admin Configuration (only used on first setup)
      INIT_SEAFILE_ADMIN_EMAIL = "benbouillet@pm.me";
      INIT_SEAFILE_ADMIN_PASSWORD = "foobarbfoo";

      # MySQL/MariaDB Configuration
      SEAFILE_MYSQL_DB_HOST = "host.containers.internal";
      SEAFILE_MYSQL_DB_PORT = toString globals.ports.mysql;
      SEAFILE_MYSQL_DB_USER = globals.users.seafile.name;
      # SEAFILE_MYSQL_DB_PASSWORD
      # INIT_SEAFILE_MYSQL_ROOT_PASSWORD
      SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
      SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
      SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seahub_db";

      # JWT Configuration
      # JWT_PRIVATE_KEY

      # Cache Configuration (Redis)
      CACHE_PROVIDER = "redis";
      REDIS_HOST = "host.containers.internal";
      REDIS_PORT = toString globals.ports.redis;
      # REDIS_PASSWORD = "";

      # Notification Server #### TO CHANGE !!!! ###
      ENABLE_NOTIFICATION_SERVER = "false";
      # INNER_NOTIFICATION_SERVER_URL = "http://notification-server:8083";
      # NOTIFICATION_SERVER_URL = "https://${domain}/notification";

      # SeaDoc Configuration (disabled - not running seadoc container)
      ENABLE_SEADOC = "false";

      # Seafile AI (disabled)
      ENABLE_SEAFILE_AI = "false";

      # Limits
      MD_FILE_COUNT_LIMIT = "100000";
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @seafile host seafile.${globals.domain}
    handle @seafile {
      reverse_proxy 127.0.0.1:${toString globals.ports.seafile}
    }
  '';
}
