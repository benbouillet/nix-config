{
  pkgs,
  lib,
  globals,
  ...
}:
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.paths.postgres} 2750 postgres postgres - -"
  ];

  networking.firewall.interfaces."podman0".allowedTCPPorts = [ globals.ports.postgres ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    dataDir = globals.zfs.databases.postgres.mountPoint;
    settings = {
      listen_addresses = lib.mkForce "*";
      port = globals.ports.postgres;
      password_encryption = "scram-sha-256";
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
}
