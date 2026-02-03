{
  config,
  lib,
  globals,
  ...
}:
let
  iGPURenderNode = "/dev/dri/renderD129";
in
{
  sops.secrets."services/gluetun/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.mediaVolumePath} 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.mediaVolumePath}/media 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.containersVolumesPath}/qbittorrent 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.containersVolumesPath}/nzbget 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.containersVolumesPath}/bazarr 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.containersVolumesPath}/sonarr 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.containersVolumesPath}/prowlarr 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.containersVolumesPath}/radarr 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.containersVolumesPath}/jellyfin-config 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.containersVolumesPath}/jellyfin-cache 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.containersVolumesPath}/jellyseerr 2770 root ${globals.groups.containers.name} - -"
  ];

  users.users."${globals.users.arr.name}" = {
    isSystemUser = true;
    createHome = false;
    uid = globals.users.arr.UID;
    group = globals.groups.containers.name;
  };

  virtualisation.oci-containers.containers = {
    "gluetun" = {
      image = "qmcgaw/gluetun:v3.41.0";
      ports = [
        "127.0.0.1:${toString globals.ports.qbittorrent}:8090" # qbittorrent
        "127.0.0.1:${toString globals.ports.nzbget}:6789" # nzbget
      ];
      devices = [
        "/dev/net/tun:/dev/net/tun"
      ];
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
      environmentFiles = [
        config.sops.secrets."services/gluetun/env".path
      ];
    };

    "qbittorrent" = {
      image = "lscr.io/linuxserver/qbittorrent:5.1.4-r1-ls436";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
        WEBUI_PORT = "8090";
      };
      volumes = [
        "${globals.containersVolumesPath}/qbittorrent:/config/:rw"
        "${globals.mediaVolumePath}/:/data/:rw"
      ];
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    "nzbget" = {
      image = "lscr.io/linuxserver/nzbget:25.4.20260130";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
      };
      volumes = [
        "${globals.containersVolumesPath}/nzbget:/config/:rw"
        "${globals.mediaVolumePath}/:/data/:rw"
      ];
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    "bazarr" = {
      image = "lscr.io/linuxserver/bazarr:1.5.5";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString globals.ports.bazarr}:6767"
      ];
      volumes = [
        "${globals.containersVolumesPath}/bazarr:/config/:rw"
        "${globals.mediaVolumePath}/:/data/:rw"
      ];
    };

    "prowlarr" = {
      image = "lscr.io/linuxserver/prowlarr:2.3.0";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString globals.ports.prowlarr}:9696"
      ];
      volumes = [
        "${globals.containersVolumesPath}/prowlarr:/config/:rw"
      ];
    };

    "radarr" = {
      image = "lscr.io/linuxserver/radarr:6.0.4";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString globals.ports.radarr}:7878"
      ];
      volumes = [
        "${globals.containersVolumesPath}/radarr:/config/:rw"
        "${globals.mediaVolumePath}/:/data/:rw"
      ];
    };

    "sonarr" = {
      image = "lscr.io/linuxserver/sonarr:4.0.16";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString globals.ports.sonarr}:8989"
      ];
      volumes = [
        "${globals.containersVolumesPath}/sonarr:/config/:rw"
        "${globals.mediaVolumePath}/:/data/:rw"
      ];
    };

    "jellyseerr" = {
      image = "fallenbagel/jellyseerr:2.7.3";
      environment = {
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString globals.ports.jellyseerr}:5055"
      ];
      volumes = [
        "${globals.containersVolumesPath}/jellyseerr:/app/config/:rw"
      ];
    };

    "jellyfin" = {
      image = "lscr.io/linuxserver/jellyfin:10.11.6";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
        JELLYFIN_PublishedServerUrl = "jellyfin.${globals.domain}";
      };
      ports = [
        "127.0.0.1:${toString globals.ports.jellyfin}:8096"
      ];
      volumes = [
        "${globals.containersVolumesPath}/jellyfin-config:/config/:rw"
        "${globals.containersVolumesPath}/jellyfin-cache:/cache/:rw"
        "${globals.mediaVolumePath}/:/data/:rw"
      ];
      devices = [
        "${iGPURenderNode}:${iGPURenderNode}:rwm"
      ];
    };
  };

  systemd.services = {
    "podman-qbittorrent" = {
      after = [ "podman-gluetun.service" ];
      requires = [ "podman-gluetun.service" ];
      partOf = [ "podman-gluetun.service" ];
    };
    "podman-nzbget" = {
      after = [ "podman-gluetun.service" ];
      requires = [ "podman-gluetun.service" ];
      partOf = [ "podman-gluetun.service" ];
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @qbittorrent host qbittorrent.${globals.domain}
    handle @qbittorrent {
      reverse_proxy 127.0.0.1:${toString globals.ports.qbittorrent}
    }

    @nzbget host nzbget.${globals.domain}
    handle @nzbget {
      reverse_proxy 127.0.0.1:${toString globals.ports.nzbget}
    }

    @bazarr host bazarr.${globals.domain}
    handle @bazarr {
      reverse_proxy 127.0.0.1:${toString globals.ports.bazarr}
    }

    @prowlarr host prowlarr.${globals.domain}
    handle @prowlarr {
      reverse_proxy 127.0.0.1:${toString globals.ports.prowlarr}
    }

    @radarr host radarr.${globals.domain}
    handle @radarr {
      reverse_proxy 127.0.0.1:${toString globals.ports.radarr}
    }

    @sonarr host sonarr.${globals.domain}
    handle @sonarr {
      reverse_proxy 127.0.0.1:${toString globals.ports.sonarr}
    }

    @jellyseerr host jellyseerr.${globals.domain}
    handle @jellyseerr {
      reverse_proxy 127.0.0.1:${toString globals.ports.jellyseerr}
    }

    @jellyfin host jellyfin.${globals.domain}
    handle @jellyfin {
      reverse_proxy 127.0.0.1:${toString globals.ports.jellyfin}
    }
  '';
}
