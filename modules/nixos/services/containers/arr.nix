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
    "d /var/cache/jellyfin 2770 root ${globals.groups.containers.name} - -"
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
      image = "qmcgaw/gluetun:v3.41.1@sha256:1a5bf4b4820a879cdf8d93d7ef0d2d963af56670c9ebff8981860b6804ebc8ab";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.qbittorrent}:8090" # qbittorrent
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.nzbget}:6789" # nzbget
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
        "--memory=512m"
      ];
    };

    "qbittorrent" = {
      image = "lscr.io/linuxserver/qbittorrent:5.1.4-r1-ls436@sha256:95114034a7f74672b76f795f6938921b0ca795f85b59b48691035dc66714f34c";
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
      image = "lscr.io/linuxserver/nzbget:26.2.20260618@sha256:b4e87d914ac382753bbab35f11e43fc1bad0f4e0b6c4f5bbcd384d60c19bce9d";
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
        "--memory=256m"
      ];
    };

    "bazarr" = {
      image = "lscr.io/linuxserver/bazarr:1.5.6@sha256:7563f01bf27554df58e10544a4bb83479258883315a31cd1c929293e908144d0";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.bazarr}:6767"
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
      image = "lscr.io/linuxserver/prowlarr:2.4.0@sha256:a46d0ce0a8236bc4e065fe7c91a55d026c9d849620c5845250519b977d8857f3";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.prowlarr}:9696"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/prowlarr:/config/:rw"
      ];
      extraOptions = [
        "--memory=192m"
      ];
    };

    "radarr" = {
      image = "lscr.io/linuxserver/radarr:6.2.1@sha256:1e95b5c13fe015361a9ae1c4d99fc2336816790aaea60fa74b2ffebe076a69e0";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.radarr}:7878"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/radarr:/config/:rw"
        "${globals.zfs.data.media.mountPoint}/:/data/:rw"
      ];
      extraOptions = [
        "--memory=386m"
      ];
    };

    "sonarr" = {
      image = "lscr.io/linuxserver/sonarr:4.0.18@sha256:916844aff737c06c12066be9146cc604c104cec66eb8e07e545cb3719a4b771a";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.sonarr}:8989"
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
      image = "ghcr.io/seerr-team/seerr:v3.3.0@sha256:c92d2dc117f62185e7bcb88cd56efd374ea79210eaf433275449e8d5988eb5a8";
      environment = {
        TZ = "Europe/Paris";
      };
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.seerr}:5055"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/seerr:/app/config/:rw"
      ];
      extraOptions = [
        "--memory=256m"
      ];
    };

    "jellyfin" = {
      image = "lscr.io/linuxserver/jellyfin:10.11.11@sha256:c123ef2f82195e377d8ca3df275f13f9dfa5c6e61b195958662b42b5e54362ab";
      environment = {
        PUID = toString globals.users.arr.UID;
        PGID = toString globals.groups.containers.GID;
        TZ = "Europe/Paris";
        JELLYFIN_PublishedServerUrl = "jellyfin.${globals.domain}";
      };
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.jellyfin}:8096"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/jellyfin-config:/config/:rw"
        # linuxserver's s6 init hardcodes JELLYFIN_CACHE_DIR=/config/cache, so
        # JELLYFIN_CACHE_DIR env var is always overridden — mount directly instead
        "/var/cache/jellyfin:/config/cache/:rw"
        "${globals.zfs.data.media.mountPoint}/:/data/:rw"
      ];
      devices = [
        "/dev/dri/render-intel:/dev/dri/renderD128:rwm"
      ];
      extraOptions = [
        "--memory=3g"
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

}
