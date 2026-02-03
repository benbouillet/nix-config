{
  pkgs,
  lib,
  globals,
  ...
}:
let
  podmanBridgeCIDR = "10.88.0.0/16";
in
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.dbPath} 2750 postgres postgres - -"
  ];

  networking.firewall.interfaces."podman0".allowedTCPPorts = [ 5432 ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    dataDir = globals.dbPath;
    settings = {
      listen_addresses = lib.mkForce "*";
      port = 5432;
    };
    authentication = ''
      # local connections over UNIX socket: still peer for convenience
      local   all             all                                     peer

      # TCP from localhost: password auth
      host    all             all             127.0.0.1/32            md5
      host    all             all             ::1/128                 md5

      # Podman bridge
      host    all             all             ${podmanBridgeCIDR}     md5
    '';
  };
}
