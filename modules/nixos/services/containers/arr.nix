{
  config,
  lib,
  ...
}:
let
  domain = "r4clette.com";
  zfsmntGID = 993;
  iGPURenderNode = "/dev/dri/renderD129";
  rootVolumesPath = "/srv/containers";
  mediaVolumePath = "/srv/media";
in
{
  sops.secrets."services/gluetun" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${rootVolumesPath}/bazarr/config/ 2775 root zfsmnt - -"
    "d ${rootVolumesPath}/qbittorrent/config/ 2775 root zfsmnt - -"
    "d ${rootVolumesPath}/nzbget/config/ 2775 root zfsmnt - -"
    "d ${rootVolumesPath}/prowlarr/config/ 2775 root zfsmnt - -"
    "d ${rootVolumesPath}/radarr/config/ 2775 root zfsmnt - -"
    "d ${rootVolumesPath}/sonarr/config/ 2775 root zfsmnt - -"
    "d ${rootVolumesPath}/jellyseerr/config/ 2775 root zfsmnt - -"
    "d ${rootVolumesPath}/jellyfin/config/ 2775 root zfsmnt - -"
    "d ${rootVolumesPath}/jellyfin/cache/ 2775 root zfsmnt - -"
  ];

  virtualisation.oci-containers.containers = {
    "gluetun" = {
      image = "qmcgaw/gluetun:v3.41.0";
      ports = [
        "127.0.0.1:9090:8090" # qbittorrent
        "127.0.0.1:9091:6789" # nzbget
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
        config.sops.secrets."services/gluetun".path
      ];
    };

    "qbittorrent" = {
      image = "lscr.io/linuxserver/qbittorrent:5.1.4";
      environment = {
        PUID = "1000";
        PGID = toString zfsmntGID;
        TZ = "Europe/Paris";
        WEBUI_PORT = "8090";
      };
      volumes = [
        "${rootVolumesPath}/qbittorrent/config/:/config/:rw"
        "${mediaVolumePath}/:/data/:rw"
      ];
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    "nzbget" = {
      image = "lscr.io/linuxserver/nzbget:25.4.20260109";
      environment = {
        PUID = "1000";
        PGID = toString zfsmntGID;
        TZ = "Europe/Paris";
      };
      volumes = [
        "${rootVolumesPath}/nzbget/config/:/config/:rw"
        "${mediaVolumePath}/:/data/:rw"
      ];
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    "bazarr" = {
      image = "lscr.io/linuxserver/bazarr:1.5.4";
      environment = {
        PUID = "1000";
        PGID = toString zfsmntGID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:9010:6767"
      ];
      volumes = [
        "${rootVolumesPath}/bazarr/config/:/config/:rw"
        "${mediaVolumePath}/:/data/:rw"
      ];
    };

    "prowlarr" = {
      image = "lscr.io/linuxserver/prowlarr:2.3.0";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:9011:9696"
      ];
      volumes = [
        "${rootVolumesPath}/prowlarr/config/:/config/:rw"
      ];
    };

    "radarr" = {
      image = "lscr.io/linuxserver/radarr:6.0.4";
      environment = {
        PUID = "1000";
        PGID = toString zfsmntGID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:9012:7878"
      ];
      volumes = [
        "${rootVolumesPath}/radarr/config/:/config/:rw"
        "${mediaVolumePath}/:/data/:rw"
      ];
    };

    "sonarr" = {
      image = "lscr.io/linuxserver/sonarr:4.0.16";
      environment = {
        PUID = "1000";
        PGID = toString zfsmntGID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:9013:8989"
      ];
      volumes = [
        "${rootVolumesPath}/sonarr/config/:/config/:rw"
        "${mediaVolumePath}/:/data/:rw"
      ];
    };

    "jellyseerr" = {
      image = "fallenbagel/jellyseerr:2.7.3";
      environment = {
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:9014:5055"
      ];
      volumes = [
        "${rootVolumesPath}/jellyseerr/config/:/app/config/:rw"
      ];
    };

    "jellyfin" = {
      image = "lscr.io/linuxserver/jellyfin:10.11.5";
      environment = {
        PUID = "1000";
        PGID = toString zfsmntGID;
        TZ = "Europe/Paris";
        JELLYFIN_PublishedServerUrl = "jellyfin.${domain}";
      };
      ports = [
        "127.0.0.1:9015:8096"
      ];
      volumes = [
        "${rootVolumesPath}/jellyfin/config/:/config/:rw"
        "${rootVolumesPath}/jellyfin/cache/:/cache/:rw"
        "${mediaVolumePath}/:/data/:rw"
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

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @qbittorrent host qbittorrent.${domain}
    handle @qbittorrent {
      reverse_proxy 127.0.0.1:9090
    }

    @nzbget host nzbget.${domain}
    handle @nzbget {
      reverse_proxy 127.0.0.1:9091
    }

    @bazarr host bazarr.${domain}
    handle @bazarr {
      reverse_proxy 127.0.0.1:9010
    }

    @prowlarr host prowlarr.${domain}
    handle @prowlarr {
      reverse_proxy 127.0.0.1:9011
    }

    @radarr host radarr.${domain}
    handle @radarr {
      reverse_proxy 127.0.0.1:9012
    }

    @sonarr host sonarr.${domain}
    handle @sonarr {
      reverse_proxy 127.0.0.1:9013
    }

    @jellyseerr host jellyseerr.${domain}
    handle @jellyseerr {
      reverse_proxy 127.0.0.1:9014
    }

    @jellyfin host jellyfin.${domain}
    handle @jellyfin {
      reverse_proxy 127.0.0.1:9015
    }
  '';
}
