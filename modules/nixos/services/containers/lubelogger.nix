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
      image = "ghcr.io/hargata/lubelogger:v1.7.3@sha256:c9d2bbb48c7f84d90e54496e2cd60422e56a5f2345c8a539ebe09f77e629d321";
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
