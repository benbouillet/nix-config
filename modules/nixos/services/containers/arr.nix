{
  config,
  lib,
  globals,
  ...
}:
{
  sops.secrets."services/gluetun/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  # We create a UDEV rule here to ensure a stable path for the GPU device node.
  # because we can't escape colons in '/dev/dri/by-path/pci-0000:00:02.0-render'
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", KERNEL=="renderD*", DRIVERS=="i915", ATTRS{vendor}=="0x8086", SYMLINK+="dri/render-intel"
  '';

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.data.media.mountPoint}/media 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.zfs.data.media.mountPoint}/torrents 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.zfs.data.media.mountPoint}/usenet 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.zfs.services.apps.mountPoint}/qbittorrent 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.zfs.services.apps.mountPoint}/nzbget 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.zfs.services.apps.mountPoint}/bazarr 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.zfs.services.apps.mountPoint}/sonarr 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.zfs.services.apps.mountPoint}/prowlarr 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.zfs.services.apps.mountPoint}/radarr 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.zfs.services.apps.mountPoint}/jellyfin-config 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.zfs.services.apps.mountPoint}/jellyfin-cache 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.zfs.services.apps.mountPoint}/seerr 2770 1000 1000 - -"
  ];

  users.users."${globals.users.arr.name}" = {
    isSystemUser = true;
    createHome = false;
    uid = globals.users.arr.UID;
    group = globals.groups.containers.name;
  };

  virtualisation.oci-containers.containers = {
    "gluetun" = {
      image = "qmcgaw/gluetun:v3.41.1";
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
      extraOptions = [
        "--memory=384m"
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
        "${globals.zfs.services.apps.mountPoint}/qbittorrent:/config/:rw"
        "${globals.zfs.data.media.mountPoint}/:/data/:rw"
      ];
      extraOptions = [
        "--network=container:gluetun"
        "--memory=128m"
      ];
    };

    "nzbget" = {
      image = "lscr.io/linuxserver/nzbget:26.0.20260227";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
      };
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/nzbget:/config/:rw"
        "${globals.zfs.data.media.mountPoint}/:/data/:rw"
      ];
      extraOptions = [
        "--network=container:gluetun"
        "--memory=128m"
      ];
    };

    "bazarr" = {
      image = "lscr.io/linuxserver/bazarr:1.5.6";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString globals.ports.bazarr}:6767"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/bazarr:/config/:rw"
        "${globals.zfs.data.media.mountPoint}/:/data/:rw"
      ];
      extraOptions = [
        "--memory=384m"
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
        "${globals.zfs.services.apps.mountPoint}/prowlarr:/config/:rw"
      ];
      extraOptions = [
        "--memory=192m"
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
        "${globals.zfs.services.apps.mountPoint}/radarr:/config/:rw"
        "${globals.zfs.data.media.mountPoint}/:/data/:rw"
      ];
      extraOptions = [
        "--memory=256m"
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
        "${globals.zfs.services.apps.mountPoint}/sonarr:/config/:rw"
        "${globals.zfs.data.media.mountPoint}/:/data/:rw"
      ];
      extraOptions = [
        "--memory=256m"
      ];
    };

    "seerr" = {
      image = "ghcr.io/seerr-team/seerr:v3.0.1";
      environment = {
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString globals.ports.seerr}:5055"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/seerr:/app/config/:rw"
      ];
      extraOptions = [
        "--memory=256m"
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
        "${globals.zfs.services.apps.mountPoint}/jellyfin-config:/config/:rw"
        "${globals.zfs.services.apps.mountPoint}/jellyfin-cache:/cache/:rw"
        "${globals.zfs.data.media.mountPoint}/:/data/:rw"
      ];
      devices = [
        "/dev/dri/render-intel:/dev/dri/renderD128:rwm"
      ];
      extraOptions = [
        "--memory=1g"
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

  services.authelia.instances."raclette".settings = {
    access_control = {
      rules = [
        {
          domain = "qbittorrent.${globals.domain}";
          policy = "one_factor";
          subject = "group:arr-admins";
        }
        {
          domain = "nzbget.${globals.domain}";
          policy = "one_factor";
          subject = "group:arr-admins";
        }
        {
          domain = "bazarr.${globals.domain}";
          policy = "one_factor";
          subject = "group:arr-admins";
        }
        {
          domain = "prowlarr.${globals.domain}";
          policy = "one_factor";
          subject = "group:arr-admins";
        }
        {
          domain = "radarr.${globals.domain}";
          policy = "one_factor";
          subject = "group:arr-admins";
        }
        {
          domain = "sonarr.${globals.domain}";
          policy = "one_factor";
          subject = "group:arr-admins";
        }
      ];
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    # Health routes
    @sonarr_ping {
      host sonarr.${globals.domain}
      path /ping
    }
    handle @sonarr_ping {
      reverse_proxy 127.0.0.1:${toString globals.ports.sonarr}
    }

    @radarr_ping {
      host radarr.${globals.domain}
      path /ping
    }
    handle @radarr_ping {
      reverse_proxy 127.0.0.1:${toString globals.ports.radarr}
    }

    @qbittorrent_ping {
      host qbittorrent.${globals.domain}
      path /api/v2/app/version
    }
    handle @qbittorrent_ping {
      reverse_proxy 127.0.0.1:${toString globals.ports.qbittorrent}
    }

    # App behind OIDC
    @qbittorrent host qbittorrent.${globals.domain}
    handle @qbittorrent {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString globals.ports.qbittorrent}
    }

    @nzbget host nzbget.${globals.domain}
    handle @nzbget {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString globals.ports.nzbget}
    }

    @bazarr host bazarr.${globals.domain}
    handle @bazarr {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString globals.ports.bazarr}
    }

    @prowlarr host prowlarr.${globals.domain}
    handle @prowlarr {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString globals.ports.prowlarr}
    }

    @radarr host radarr.${globals.domain}
    handle @radarr {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString globals.ports.radarr}
    }

    @sonarr host sonarr.${globals.domain}
    handle @sonarr {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString globals.ports.sonarr}
    }

    # Available on tailnet
    @seerr host seerr.${globals.domain}
    handle @seerr {
      reverse_proxy 127.0.0.1:${toString globals.ports.seerr}
    }

    @jellyfin host jellyfin.${globals.domain}
    handle @jellyfin {
      reverse_proxy 127.0.0.1:${toString globals.ports.jellyfin}
    }
  '';
}
