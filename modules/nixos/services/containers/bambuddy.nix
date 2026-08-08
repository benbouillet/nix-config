{
  lib,
  globals,
  ...
}:
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.services.apps.mountPoint}/bambuddy/data 2770 1000 1000 - -"
    "d ${globals.zfs.services.apps.mountPoint}/bambuddy/logs 2770 1000 1000 - -"
  ];

  virtualisation.oci-containers.containers = {
    "bambuddy" = {
      image = "ghcr.io/maziggy/bambuddy:1.2.5.2";
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/bambuddy/data:/app/data"
        "${globals.zfs.services.apps.mountPoint}/bambuddy/logs:/app/logs"
      ];
      environment = {
        TZ = "Europe/Paris";
        PORT = toString globals.ports.bambuddy;
        PUID = "1000";
        PGID = "1000";
      };
      extraOptions = [
        "--network=host"
        "--cap-add=NET_BIND_SERVICE"
        "--memory=512m"
        "--pids-limit=128"
      ];
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control = {
      rules = [
        {
          domain = "bambuddy.${globals.domain}";
          policy = "one_factor";
          subject = "group:3d";
        }
      ];
    };
  };
}
