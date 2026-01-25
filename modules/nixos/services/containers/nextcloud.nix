{
  lib,
  ...
}:
let
  domain = "r4clette.com";
  ports = {
    nextcloud = 9040;
    authelia = 9091;
  };
  users = {
    nextcloud = {
      name = "nextcloud";
      UID = 940;
    };
  };
  groups = {
    containers = {
      name = "containers";
      GID = 993;
    };
    oidc = {
      name = "oidc";
      GID = 931;
    };
  };
  dataPath = "/srv/nextcloud";
  containersVolumesPath = "/srv/containers";
in
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${dataPath} 2770 root ${groups.containers.name} - -"
    "d ${containersVolumesPath}/nextcloud 2770 root ${groups.containers.name} - -"
  ];

  users.users."${users.nextcloud.name}" = {
    isSystemUser = true;
    createHome = false;
    uid = users.nextcloud.UID;
    group = groups.containers.name;
    extraGroups = [ groups.oidc.name ];
  };

  services.postgresql = {
    enable = lib.mkForce true;
    ensureDatabases = lib.mkAfter [
      "nextcloud"
    ];
    ensureUsers = lib.mkAfter [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
          connection_limit = 5;
          password = "SCRAM-SHA-256$4096:Cc/AgwrBKpl+BzAfjHoC3Q==$YvNfzHFoe5NkSAcwyqzZ1HYtpv6SS5alQNE0e9+ZKQg=:KCsAXDaEAyRmG8vcCzJMQm2LRz9QZS9n46NzPq5Pgc0=";
        };
      }
    ];
  };

  virtualisation.oci-containers.containers = {
    "nextcloud" = {
      image = "lscr.io/linuxserver/nextcloud:32.0.5-ls412";
      environment = {
        PUID = toString users.nextcloud.UID;
        PGID = toString groups.containers.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString ports.nextcloud}:80"
      ];
      volumes = [
        "${containersVolumesPath}/nextcloud/:/config/:rw"
        "${dataPath}/:/data/:rw"
      ];
      extraOptions = [
        "--add-host=auth.r4clette.com:host-gateway"
      ];
    };
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @nextcloud host nextcloud.${domain}
    handle @nextcloud {
      reverse_proxy 127.0.0.1:${toString ports.nextcloud}
    }
  '';
}
