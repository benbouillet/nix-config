{
  config,
  lib,
  ...
}:
let
  domain = "r4clette.com";
  ports = {
    bazarr = 9010;
    prowlarr = 9011;
    radarr = 9012;
    sonarr = 9013;
    jellyseerr = 9014;
    jellyfin = 9015;
    qbittorrent = 9016;
    nzbget = 9017;
  };
  arrUser = {
    name = "arr";
    UID = 920;
  };
  containersGroup = {
    name = "containers";
    GID = 993;
  };
  iGPURenderNode = "/dev/dri/renderD129";
  mediaVolumePath = "/srv/arrdata";
  containersVolumesPath = "/srv/containers";
in
{
  sops.secrets."services/gluetun" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${mediaVolumePath} 2770 root ${containersGroup.name} - -"
    "d ${mediaVolumePath}/media 2770 root ${containersGroup.name} - -"
    "d ${containersVolumesPath}/qbittorrent 2770 root ${containersGroup.name} - -"
    "d ${containersVolumesPath}/nzbget 2770 root ${containersGroup.name} - -"
    "d ${containersVolumesPath}/bazarr 2770 root ${containersGroup.name} - -"
    "d ${containersVolumesPath}/sonarr 2770 root ${containersGroup.name} - -"
    "d ${containersVolumesPath}/prowlarr 2770 root ${containersGroup.name} - -"
    "d ${containersVolumesPath}/radarr 2770 root ${containersGroup.name} - -"
    "d ${containersVolumesPath}/jellyfin-config 2770 root ${containersGroup.name} - -"
    "d ${containersVolumesPath}/jellyfin-cache 2770 root ${containersGroup.name} - -"
    "d ${containersVolumesPath}/jellyseerr 2770 root ${containersGroup.name} - -"
  ];

  users.users."${arrUser.name}" = {
    isSystemUser = true;
    createHome = false;
    uid = arrUser.UID;
    group = containersGroup.name;
  };

  virtualisation.oci-containers.containers = {
    "gluetun" = {
      image = "qmcgaw/gluetun:v3.41.0";
      ports = [
        "127.0.0.1:${toString ports.qbittorrent}:8090" # qbittorrent
        "127.0.0.1:${toString ports.nzbget}:6789" # nzbget
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
      image = "lscr.io/linuxserver/qbittorrent:5.1.4-r1-ls436";
      environment = {
        PUID = toString arrUser.UID;
        PGID = toString containersGroup.GID;
        TZ = "Europe/Paris";
        WEBUI_PORT = "8090";
      };
      volumes = [
        "${containersVolumesPath}/qbittorrent:/config/:rw"
        "${mediaVolumePath}/:/data/:rw"
      ];
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    "nzbget" = {
      image = "lscr.io/linuxserver/nzbget:25.4.20260109";
      environment = {
        PUID = toString arrUser.UID;
        PGID = toString containersGroup.GID;
        TZ = "Europe/Paris";
      };
      volumes = [
        "${containersVolumesPath}/nzbget:/config/:rw"
        "${mediaVolumePath}/:/data/:rw"
      ];
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    "bazarr" = {
      image = "lscr.io/linuxserver/bazarr:1.5.4";
      environment = {
        PUID = toString arrUser.UID;
        PGID = toString containersGroup.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString ports.bazarr}:6767"
      ];
      volumes = [
        "${containersVolumesPath}/bazarr:/config/:rw"
        "${mediaVolumePath}/:/data/:rw"
      ];
    };

    "prowlarr" = {
      image = "lscr.io/linuxserver/prowlarr:2.3.0";
      environment = {
        PUID = toString arrUser.UID;
        PGID = toString containersGroup.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString ports.prowlarr}:9696"
      ];
      volumes = [
        "${containersVolumesPath}/prowlarr:/config/:rw"
      ];
    };

    "radarr" = {
      image = "lscr.io/linuxserver/radarr:6.0.4";
      environment = {
        PUID = toString arrUser.UID;
        PGID = toString containersGroup.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString ports.radarr}:7878"
      ];
      volumes = [
        "${containersVolumesPath}/radarr:/config/:rw"
        "${mediaVolumePath}/:/data/:rw"
      ];
    };

    "sonarr" = {
      image = "lscr.io/linuxserver/sonarr:4.0.16";
      environment = {
        PUID = toString arrUser.UID;
        PGID = toString containersGroup.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString ports.sonarr}:8989"
      ];
      volumes = [
        "${containersVolumesPath}/sonarr:/config/:rw"
        "${mediaVolumePath}/:/data/:rw"
      ];
    };

    "jellyseerr" = {
      image = "fallenbagel/jellyseerr:2.7.3";
      environment = {
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString ports.jellyseerr}:5055"
      ];
      volumes = [
        "${containersVolumesPath}/jellyseerr:/app/config/:rw"
      ];
    };

    "jellyfin" = {
      image = "lscr.io/linuxserver/jellyfin:10.11.6";
      environment = {
        PUID = toString arrUser.UID;
        PGID = toString containersGroup.GID;
        TZ = "Europe/Paris";
        JELLYFIN_PublishedServerUrl = "jellyfin.${domain}";
      };
      ports = [
        "127.0.0.1:${toString ports.jellyfin}:8096"
      ];
      volumes = [
        "${containersVolumesPath}/jellyfin-config:/config/:rw"
        "${containersVolumesPath}/jellyfin-cache:/cache/:rw"
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
      reverse_proxy 127.0.0.1:${toString ports.qbittorrent}
    }

    @nzbget host nzbget.${domain}
    handle @nzbget {
      reverse_proxy 127.0.0.1:${toString ports.nzbget}
    }

    @bazarr host bazarr.${domain}
    handle @bazarr {
      reverse_proxy 127.0.0.1:${toString ports.bazarr}
    }

    @prowlarr host prowlarr.${domain}
    handle @prowlarr {
      reverse_proxy 127.0.0.1:${toString ports.prowlarr}
    }

    @radarr host radarr.${domain}
    handle @radarr {
      reverse_proxy 127.0.0.1:${toString ports.radarr}
    }

    @sonarr host sonarr.${domain}
    handle @sonarr {
      reverse_proxy 127.0.0.1:${toString ports.sonarr}
    }

    @jellyseerr host jellyseerr.${domain}
    handle @jellyseerr {
      reverse_proxy 127.0.0.1:${toString ports.jellyseerr}
    }

    @jellyfin host jellyfin.${domain}
    handle @jellyfin {
      reverse_proxy 127.0.0.1:${toString ports.jellyfin}
    }
  '';
}
