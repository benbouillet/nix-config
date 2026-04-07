{
  lib,
  globals,
  ...
}:
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.services.apps.mountPoint}/lubelogger 2770 1000 1000 - -"
  ];

  virtualisation.oci-containers.containers = {
    "lubelogger" = {
      image = "ghcr.io/hargata/lubelogger:v1.6.3@sha256:35daede9d9675cc979cde1cfe08cae8eb7fe92506e890445bb6bde5533daa624";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.lubelogger}:8080"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/lubelogger:/App/data"
      ];
      extraOptions = [
        "--memory=512m"
        "--pids-limit=24"
      ];
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "lubelogger.${globals.domain}";
        policy = "one_factor";
        subject = "group:lubelogger";
      }
    ];
  };

  
}
