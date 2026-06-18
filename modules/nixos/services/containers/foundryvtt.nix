{
  lib,
  globals,
  config,
  ...
}:
{
  sops.secrets."services/foundryvtt/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.services.apps.mountPoint}/foundryvtt 2770 1000 1000 - -"
  ];

  virtualisation.oci-containers.containers = {
    "foundryvtt" = {
      image = "ghcr.io/felddy/foundryvtt:14.364.0@sha256:097f876d9c79f074380e219bf93753fa1916f31624637776fcf23c2dd3bb07fa";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.foundryvtt}:30000"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/foundryvtt:/data"
      ];
      environment = {
        CONTAINER_PRESERVE_CONFIG = "true";
      };
      environmentFiles = [
        config.sops.secrets."services/foundryvtt/env".path
      ];
      extraOptions = [
        "--memory=1g"
        "--pids-limit=24"
        "--no-healthcheck"
      ];
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "dnd.${globals.domain}";
        policy = "one_factor";
        subject = "group:dnd";
      }
    ];
  };

}
