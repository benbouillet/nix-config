{
  pkgs,
  config,
  lib,
  ...
}:
let
  domain = "r4clette.com";
  rootVolumesPath = "/srv/containers";
  services = {
    "2048" = {
      image = "alexwhen/docker-2048@sha256:4913452e5bd092db9c8b005523127b8f62821867021e23a9acb1ae0f7d2432e1";
      isExposed = true;
      hostPort = 9001;
      containerPort = 80;
      useSopsSecrets = false;
    };
    # "dnd" = {
    #   image = "felddy/foundryvtt:13.346.0";
    #   hostPort = 9002;
    #   containerPort = 30000;
    #   useSopsSecrets = true;
    #   environment = {
    #     CONTAINER_PRESERVE_CONFIG = "true";
    #   };
    # };
    "gluetun" = {
      image = "qmcgaw/gluetun:v3.41.0";
      devices = [ "/dev/net/tun:/dev/net/tun" ];
      capabilities = {
        NET_ADMIN = true;
      };
      environment = {
        VPN_SERVICE_PROVIDER = "protonvpn";
        VPN_TYPE = "wireguard";
        SERVER_COUNTRIES = "Switzerland";
        PORT_FORWARD_ONLY = "on";
        WIREGUARD_MTU = "1400";
      };
      useSopsSecrets = true;
    };
    "debian" = {
      image = "debian:bookworm-slim";
      cmd = [
        "/bin/bash"
        "-c"
        "sleep 3600"
      ];
      usesVPN = true;
    };
  };

  withDefaults =
    name: s:
    s
    // {
      isExposed = s.isExposed or false;
      cmd = s.cmd or [ ];
      useSopsSecrets = s.useSopsSecrets or false;
      usesVPN = s.usesVPN or false;
      environment = s.environment or { };
      extraOptions = s.extraOptions or [ ];
      devices = s.devices or [ ];
      volumes = s.volumes or [ ];
      capabilities = s.capabilities or { };
      dependsOn = s.dependsOn or [ ];
    };

  # normalized services with defaults
  services' = lib.mapAttrs withDefaults services;

  mkContainers =
    name: s:
    lib.nameValuePair name {
      image = s.image;
      autoStart = true;
      cmd = s.cmd;
      ports =
        if s.isExposed then [ "127.0.0.1:${toString s.hostPort}:${toString s.containerPort}" ] else [ ];
      environment = s.environment;
      environmentFiles =
        if s.useSopsSecrets then [ config.sops.secrets."services/${name}".path ] else [ ];
      extraOptions = s.extraOptions ++ (if s.usesVPN then [ "--network=container:gluetun" ] else [ ]);
      dependsOn = s.dependsOn ++ (if s.usesVPN then [ "gluetun" ] else [ ]);
      devices = s.devices;
      volumes = if s.volumes != [ ] then map (x: rootVolumesPath + x + ":" + x) s.volumes else [ ];
      capabilities = s.capabilities;
    };

  sopsSecretsDynamic = lib.mapAttrs' (
    name: _s:
    lib.nameValuePair "services/${name}" {
      mode = "0400";
      owner = "root";
      group = "root";
    }
  ) (lib.filterAttrs (_: s: s.useSopsSecrets) services');

  exposedServices = lib.filterAttrs (_: s: s.isExposed) services';

  renderedRoutes = lib.mapAttrsToList (k: v: ''
    @${k} host ${k}.${domain}
    handle @${k} {
      reverse_proxy 127.0.0.1:${toString v.hostPort}
    }
  '') exposedServices;

  routes = lib.concatStringsSep "\n" renderedRoutes;

  hostVolumePathsFor = s: map (x: rootVolumesPath + x) s.volumes;

  allHostVolumePaths = lib.unique (
    lib.concatLists (lib.mapAttrsToList (_: s: hostVolumePathsFor s) services')
  );

  volumeTmpfilesRules = map (p: "d ${p} 0750 root root - -") allHostVolumePaths;
in
{
  sops.secrets = lib.mkMerge [
    sopsSecretsDynamic
  ];

  # Create host mountpoints for bind mounts
  systemd.tmpfiles.rules = volumeTmpfilesRules;
  # Make sure tmpfiles has run before containers come up
  systemd.services."podman-oci-containers".after = [
    "zfs-mount.service"
    "systemd-tmpfiles-setup.service"
  ];
  systemd.services."podman-oci-containers".requires = [
    "zfs-mount.service"
    "systemd-tmpfiles-setup.service"
  ];

  virtualisation = {
    podman.enable = true;
    oci-containers = {
      backend = "podman";
      containers = lib.listToAttrs (lib.mapAttrsToList mkContainers services');
    };
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter routes;

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
