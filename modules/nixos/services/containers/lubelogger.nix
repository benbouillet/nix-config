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
      image = "ghcr.io/hargata/lubelogger:v1.6.5@sha256:293604d85b021b6489ef3d0b22c792cefcc802bf8eec0b5c4766a4a979b8a998";
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
