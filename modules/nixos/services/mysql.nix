{
  pkgs,
  globals,
  config,
  ...
}:
{
  sops.secrets."mysql/env" = {
    mode = "0400";
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = globals.zfs.databases.mysql.mountPoint;
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
}
