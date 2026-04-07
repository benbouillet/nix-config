{
  globals,
  config,
  lib,
  ...
}:
{
  sops.secrets."vaultwarden/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  services.postgresql = {
    enable = lib.mkForce true;
    ensureDatabases = lib.mkAfter [
      "vaultwarden"
    ];
    ensureUsers = lib.mkAfter [
      {
        name = "vaultwarden";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
          connection_limit = 20;
        };
      }
    ];
  };

  systemd.services."vaultwarden" = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  services.vaultwarden = {
    enable = true;
    domain = "vault.${globals.domain}";
    dbBackend = "postgresql";
    config = {
      SIGNUPS_ALLOWED = true;
      ROCKET_ADDRESS = "${globals.hosts.chewie.ipv4}";
      ROCKET_PORT = globals.ports.vaultwarden;
      ROCKET_LOG = "error";
      SMTP_HOST = "smtp.protonmail.ch";
      SMTP_FROM = "admin@${globals.domain}";
      SMTP_FROM_NAME = "Raclette Admin";
      SMTP_PORT = "587";
      SMTP_SECURITY = "starttls";
      SMTP_USERNAME = "admin@${globals.domain}";
      SMTP_TIMEOUT = "15";
    };
    environmentFile = config.sops.secrets."vaultwarden/env".path;
  };
}
