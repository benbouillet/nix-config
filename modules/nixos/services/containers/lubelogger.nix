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
      image = "ghcr.io/hargata/lubelogger:v1.6.4@sha256:82a41d7ebda9b47ce70ab55b590ea597f90ebee56877e6a99b4b786cf2f4432b";
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
