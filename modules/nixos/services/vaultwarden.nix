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
          password = "SCRAM-SHA-256$4096:9eDc5jPSOR/GGiqwDn9oVg==$h64D93+wBWXwF+tLiEz8cq9cXrvQvbZ8Kuf7ms9bSKY=:JfQacPMggQ1rBpbUZz+dRKZ+f+l1ww2uwDe9Uv6zXhM=";
        };
      }
    ];
  };

  systemd.services."podman-vaultwarden" = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  services.vaultwarden = {
    enable = true;
    domain = "vault.${globals.domain}";
    dbBackend = "postgresql";
    config = {
      SIGNUPS_ALLOWED = true;
      ROCKET_ADDRESS = "127.0.0.1";
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

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @vault host vault.${globals.domain}
    handle @vault {
      reverse_proxy 127.0.0.1:${toString globals.ports.vaultwarden}
    }
  '';
}
