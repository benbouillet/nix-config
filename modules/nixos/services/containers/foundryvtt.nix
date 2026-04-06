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
      image = "ghcr.io/felddy/foundryvtt:14.359.0";
      ports = [
        "127.0.0.1:${toString globals.ports.foundryvtt}:30000"
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

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @foundryvtt host dnd.${globals.domain}
    handle @foundryvtt {
      reverse_proxy 127.0.0.1:${toString globals.ports.foundryvtt}
    }
  '';
}
