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
      image = "ghcr.io/hargata/lubelogger:v1.7.1@sha256:678a5c4af387e525f06ef954b454efe536745f517f2078dc646ccce9332adb9d";
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
