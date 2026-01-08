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
    # "dnd" = {
    #   image = "felddy/foundryvtt:13.346.0";
    #   hostPort = 9002;
    #   containerPort = 30000;
    #   useSopsSecrets = true;
    #   environment = {
    #     CONTAINER_PRESERVE_CONFIG = "true";
    #   };
    # };
    # foundryvtt
    # freshrss
    # jellyfin
    # jellyseerr
    # lubelogger
    # pihole
    # prowlarr
    # radarr
    # searxng
    # searxng_config.yml
    # sonarr
    # "gluetun" = {
    #   image = "qmcgaw/gluetun:v3.41.0";
    #   devices = [ "/dev/net/tun:/dev/net/tun" ];
    #   capabilities = {
    #     NET_ADMIN = true;
    #   };
    #   environment = {
    #     VPN_SERVICE_PROVIDER = "protonvpn";
    #     VPN_TYPE = "wireguard";
    #     SERVER_COUNTRIES = "Switzerland";
    #     PORT_FORWARD_ONLY = "on";
    #     WIREGUARD_MTU = "1400";
    #   };
    #   useSopsSecrets = true;
    # };
    "chat" = {
      image = "ghcr.io/open-webui/open-webui:main-slim";
      isExposed = true;
      hostPort = 9020;
      containerPort = 8080;
      devices = [
        "nvidia.com/gpu=all"
      ];
      volumes = [
        "${rootVolumesPath}/openwebui/open-webui:/app/backend/data:rw"
      ];
    };
    "ollama" = {
      image = "ollama/ollama:0.13.5";
      isExposed = true;
      hostPort = 9021;
      containerPort = 11434;
      devices = [
        "nvidia.com/gpu=all"
      ];
      volumes = [
        "${rootVolumesPath}/ollama:/root/.ollama:rw"
      ];
      extraOptions = [
        "--network=container:chat"
      ];
    };
    "search" = {
      image = "itzcrazykns1337/perplexica:v1.12.0";
      isExposed = true;
      hostPort = 9022;
      containerPort = 3000;
      volumes = [
        "${rootVolumesPath}/perplexica:/home/perplexica/data:rw"
      ];
    };
    # "steam" = {
    #   image = "josh5/steam-headless:latest";
    #   isExposed = true;
    #   hostPort = 9010;
    #   containerPort = 8083;
    #   useSopsSecrets = false;
    #   environment = {
    #     TZ = "Europe/Paris";
    #     NAME = "SteamHeadless";
    #     DISPLAY = ":55";
    #     GAMES_DIR = "/mnt/games";
    #     PUID = "1000";
    #     PGID = "1000";
    #     UMASK = "000";
    #     USER_PASSWORD = "password";
    #     MODE = "primary";
    #     WEB_UI_MODE = "vnc";
    #     ENABLE_VNC_AUDIO = "true";
    #     PORT_NOVNC_WEB = "8083";
    #     ENABLE_STEAM = "true";
    #     STEAM_ARGS = "-silent";
    #     ENABLE_SUNSHINE = "true";
    #     SUNSHINE_USER = "ben";
    #     SUNSHINE_PASS = "foo";
    #     ENABLE_EVDEV_INPUTS = "true";
    #     FORCE_X11_DUMMY_CONFIG = "true";
    #     NVIDIA_DRIVER_CAPABILITIES = "all";
    #     NVIDIA_VISIBLE_DEVICES = "all";
    #   };
    #   capabilities = {
    #     NET_ADMIN = true;
    #     SYS_ADMIN = true;
    #     SYS_NICE = true;
    #   };
    #   devices = [
    #     "/dev/fuse:/dev/fuse"
    #     "/dev/uinput:/dev/uinput"
    #     "nvidia.com/gpu=all"
    #   ];
    #   volumes = [
    #     "${rootVolumesPath}/steam-headless/home/default:/home/default:rw"
    #     "${rootVolumesPath}/steam-headless/games:/mnt/games:rw"
    #     "/opt/container-data/steam-headless/sockets/.X11-unix:/tmp/.X11-unix:rw"
    #     "/opt/container-data/steam-headless/sockets/pulse:/tmp/pulse:rw"
    #   ];
    #   extraOptions = [
    #     "--ipc=host"
    #     "--ulimit=nofile=1024:524288"
    #     "--security-opt=seccomp=unconfined"
    #     "--security-opt=apparmor=unconfined"
    #     "--device-cgroup-rule=c 13:* rmw"
    #   ];
    # };
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
      volumes = s.volumes;
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

  hostFromVolume = v: lib.head (lib.splitString ":" v);

  allHostVolumePaths = lib.unique (
    lib.concatLists (lib.mapAttrsToList (_: s: map hostFromVolume s.volumes) services')
  );

  volumeTmpfilesRules = map (p: "d ${p} 2775 root zfsmnt - -") allHostVolumePaths;
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
