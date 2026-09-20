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
      image = "ghcr.io/felddy/foundryvtt:14.368.0@sha256:8ec86078b0c461644d896cbe3a9f9bcae7d1ce8dc8d91eeb0b0f1d94c91c072f";
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
