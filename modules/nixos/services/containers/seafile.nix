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
    volumes = [
      "/srv/seafile:/shared/seafile"
    ];
    ports = [ "127.0.0.1:${toString globals.ports.seafile}:80" ];
    extraOptions = [
      "--health-cmd=curl -sf -H 'Host: seafile.${globals.domain}' http://localhost/ || exit 1"
      "--health-interval=30s"
      "--health-timeout=10s"
      "--health-retries=5"
      "--health-start-period=120s"
    ];
    environmentFiles = [ config.sops.secrets."services/seafile/env".path ];
    environment = {
      SEAFILE_SERVER_HOSTNAME = "seafile.${globals.domain}";
      SEAFILE_SERVER_PROTOCOL = "https";
      FORCE_HTTPS_IN_CONF = "true";
      TIME_ZONE = "Etc/UTC";
      SITE_ROOT = "/";
      NON_ROOT = "false";
      SEAFILE_LOG_TO_STDOUT = "true";

      # MySQL/MariaDB Configuration
      SEAFILE_MYSQL_DB_HOST = "host.containers.internal";
      SEAFILE_MYSQL_DB_PORT = toString globals.ports.mysql;
      SEAFILE_MYSQL_DB_USER = globals.users.seafile.name;
      SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
      SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
      SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seahub_db";

      # Cache Configuration (Redis)
      CACHE_PROVIDER = "redis";
      REDIS_HOST = "host.containers.internal";
      REDIS_PORT = toString globals.ports.redis;

      # Notification Server #### TO CHANGE !!!! ###
      ENABLE_NOTIFICATION_SERVER = "true";
      INNER_NOTIFICATION_SERVER_URL = "http://seafile-notification-server:8083";
      NOTIFICATION_SERVER_URL = "https://seafile.${globals.domain}/notification";

      # SeaDoc Configuration (disabled - not running seadoc container)
      ENABLE_SEADOC = "false";

      # Seafile AI (disabled)
      ENABLE_SEAFILE_AI = "false";

      # Limits
      MD_FILE_COUNT_LIMIT = "100000";
    };
  };

  virtualisation.oci-containers.containers.seafile-notification-server = {
    image = "seafileltd/notification-server:13.0.10";
    autoStart = true;
    volumes = [
      "/srv/seafile:/shared/seafile"
    ];
    ports = [ "127.0.0.1:${toString globals.ports.seafile-notification-server}:8083" ];
    environmentFiles = [ config.sops.secrets."services/seafile/env".path ];
    environment = {
      SEAFILE_MYSQL_DB_HOST = "host.containers.internal";
      SEAFILE_MYSQL_DB_PORT = toString globals.ports.mysql;
      SEAFILE_MYSQL_DB_USER = globals.users.seafile.name;
      SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
      SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
      SEAFILE_LOG_TO_STDOUT = "true";
      NOTIFICATION_SERVER_LOG_LEVEL = "info";
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control = {
      rules = [
        {
          domain = "seafile.${globals.domain}";
          policy = "one_factor";
          subject = "group:debug";
        }
      ];
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @seafile host seafile.${globals.domain}
    handle @seafile {
      @notif path /notification*
      handle @notif {
        reverse_proxy 127.0.0.1:${toString globals.ports.seafile-notification-server}
      }

      @api path /api2/* /api/v2.1/* /seafhttp* /seafdav*
      handle @api {
        reverse_proxy 127.0.0.1:${toString globals.ports.seafile}
      }

      handle {
        forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
          uri /api/verify?rd=https://auth.${globals.domain}
          copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
        }

        reverse_proxy 127.0.0.1:${toString globals.ports.seafile}
      }
    }
  '';
}
