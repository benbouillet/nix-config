{
  pkgs,
  lib,
  ...
}:
let
  domain = "r4clette.com";
  services = {
    "2048" = {
      image = "alexwhen/docker-2048@sha256:4913452e5bd092db9c8b005523127b8f62821867021e23a9acb1ae0f7d2432e1";
      hostPort = 9001;
      containerPort = 80;
    };
  };

  mkContainers = name: s:
    lib.nameValuePair name {
      image = s.image;
      autoStart = true;
      ports = [ "127.0.0.1:${toString s.hostPort}:${toString s.containerPort}" ];
      extraOptions = s.extraOptions or [];
    };

  renderedRoutes = lib.mapAttrsToList (k: v: ''
    @${k} host ${k}.${domain}
    handle @${k} {
      reverse_proxy 127.0.0.1:${toString v.hostPort}
    }
  '') services;

  routes = lib.concatStringsSep "\n" renderedRoutes;

in {
  virtualisation = {
    podman.enable = true;
    oci-containers = {
      backend = "podman";
      containers = lib.listToAttrs (lib.mapAttrsToList mkContainers services);
    };
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig =
    lib.mkAfter routes;

  # OCI Containers auto-repair systemd service
  systemd.services.container-auto-repair = {
    description = "Restart unhealthy OCI containers (podman)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "container-auto-repair" ''
        set -euo pipefail

        # List unhealthy containers (names). Ignore if none.
        mapfile -t bad < <(${pkgs.podman}/bin/podman ps \
          --filter health=unhealthy \
          --format '{{.Names}}')

        if [ "''${#bad[@]}" -eq 0 ]; then
          exit 0
        fi

        for c in "''${bad[@]}"; do
          echo "Restarting unhealthy container: $c"
          ${pkgs.podman}/bin/podman restart "$c" || true
        done
      '';
    };
  };

  systemd.timers.container-auto-repair = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "1min"; # run every minute
      Unit = "container-auto-repair.service";
    };
  };
}
