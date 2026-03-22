{
  pkgs,
  lib,
  config,
  globals,
  ...
}:
{
  networking.firewall.interfaces."podman0".allowedTCPPorts = [ globals.ports.postgres ];

  sops.secrets."postgresql/lldap" = {
    owner = "postgres";
    mode = "0400";
  };
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
  sops.secrets."postgresql/paperless" = {
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
    authentication = ''
      # local connections over UNIX socket: still peer for convenience
      local   all             all                                     peer

      # TCP from localhost: password auth
      host    all             all             127.0.0.1/32            md5
      host    all             all             ::1/128                 md5

      # Podman bridge
      host    all             all             ${globals.podmanBridgeCIDR}     md5
    '';
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
      psql -tAc "ALTER ROLE lldap PASSWORD '$(cat ${config.sops.secrets."postgresql/lldap".path})';"
      psql -tAc "ALTER ROLE authelia PASSWORD '$(cat ${config.sops.secrets."postgresql/authelia".path})';"
      psql -tAc "ALTER ROLE immich PASSWORD '$(cat ${config.sops.secrets."postgresql/immich".path})';"
      psql -tAc "ALTER ROLE vaultwarden PASSWORD '$(cat ${config.sops.secrets."postgresql/vaultwarden".path})';"
      psql -tAc "ALTER ROLE mealie PASSWORD '$(cat ${config.sops.secrets."postgresql/mealie".path})';"
      psql -tAc "ALTER ROLE paperless PASSWORD '$(cat ${config.sops.secrets."postgresql/paperless".path})';"
    '';
  };
}
