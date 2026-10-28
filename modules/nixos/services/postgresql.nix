{
  pkgs,
  lib,
  config,
  globals,
  ...
}:
{
  networking.firewall.interfaces."podman0".allowedTCPPorts = [ globals.ports.postgres ];

  sops.secrets."postgresql/authelia" = {
    owner = "postgres";
    mode = "0400";
  };
  sops.secrets."postgresql/immich" = {
    owner = "postgres";
    mode = "0400";
  };
  sops.secrets."postgresql/vaultwarden" = {
    owner = "postgres";
    mode = "0400";
  };
  sops.secrets."postgresql/mealie" = {
    owner = "postgres";
    mode = "0400";
  };
  sops.secrets."postgresql/degoog" = {
    owner = "postgres";
    mode = "0400";
  };
  sops.secrets."postgresql/paperless" = {
    owner = "postgres";
    mode = "0400";
  };
  sops.secrets."postgresql/kestra" = {
    owner = "postgres";
    mode = "0400";
  };
  sops.secrets."postgresql/litellm" = {
    owner = "postgres";
    mode = "0400";
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18.withPackages (p: [
      p.pgvector
      p.vectorchord
    ]);
    dataDir = globals.zfs.databases.postgres.mountPoint;
    settings = {
      listen_addresses = lib.mkForce "127.0.0.1,${globals.podmanBridgeGateway}";
      port = globals.ports.postgres;
      password_encryption = "scram-sha-256";
      shared_preload_libraries = "vchord.so";
    };
    authentication = lib.mkForce ''
      # Unix socket: peer (authelia, postgres superuser, postgresql-passwords oneshot)
      local   all          all                                  peer

      # Native loopback clients
      host    immich       immich       127.0.0.1/32            scram-sha-256
      host    vaultwarden  vaultwarden  127.0.0.1/32            scram-sha-256

      # Podman bridge containers
      host    mealie       mealie       ${globals.podmanBridgeCIDR}  scram-sha-256
      host    paperless    paperless    ${globals.podmanBridgeCIDR}  scram-sha-256
      host    kestra       kestra       ${globals.podmanBridgeCIDR}  scram-sha-256
      host    litellm      litellm      ${globals.podmanBridgeCIDR}  scram-sha-256
      host    degoog       degoog       ${globals.podmanBridgeCIDR}  scram-sha-256
    '';
  };

  systemd.services.postgresql = {
    after = [ "podman-bridge-ready.service" ];
    requires = [ "podman-bridge-ready.service" ];
  };

  systemd.services.postgresql-passwords = {
    description = "Set PostgreSQL role passwords from sops secrets";
    after = [ "postgresql-setup.service" ];
    requires = [ "postgresql-setup.service" ];
    wantedBy = [ "postgresql.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      RemainAfterExit = true;
    };
    path = [ config.services.postgresql.finalPackage ];
    environment.PGPORT = toString config.services.postgresql.settings.port;
    script = ''
      set -euo pipefail
      psql -tAc "ALTER ROLE authelia PASSWORD '$(cat ${config.sops.secrets."postgresql/authelia".path})';"
      psql -tAc "ALTER ROLE immich PASSWORD '$(cat ${config.sops.secrets."postgresql/immich".path})';"
      psql -tAc "ALTER ROLE vaultwarden PASSWORD '$(cat ${
        config.sops.secrets."postgresql/vaultwarden".path
      })';"
      psql -tAc "ALTER ROLE mealie PASSWORD '$(cat ${config.sops.secrets."postgresql/mealie".path})';"
      psql -tAc "ALTER ROLE paperless PASSWORD '$(cat ${
        config.sops.secrets."postgresql/paperless".path
      })';"
      psql -tAc "ALTER ROLE kestra PASSWORD '$(cat ${config.sops.secrets."postgresql/kestra".path})';"
      psql -tAc "ALTER ROLE litellm PASSWORD '$(cat ${config.sops.secrets."postgresql/litellm".path})';"
      psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='degoog'" | grep -q 1 || psql -tAc "CREATE ROLE degoog WITH LOGIN;"
      psql -tAc "SELECT 1 FROM pg_database WHERE datname='degoog'" | grep -q 1 || psql -tAc "CREATE DATABASE degoog OWNER degoog;"
      psql -tAc "ALTER ROLE degoog PASSWORD '$(cat ${config.sops.secrets."postgresql/degoog".path})';"
    '';
  };
}
