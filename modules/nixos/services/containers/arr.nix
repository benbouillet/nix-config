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
      image = "lscr.io/linuxserver/nzbget:26.1.20260417@sha256:9cbe95f67ce96c9d18547dc3c10766b5def33217934afa87e11760167a7bd27d";
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
      image = "lscr.io/linuxserver/bazarr:1.5.6@sha256:21a4813c5ba120d72ac5f54869b790792bda0784205268eccbc204adb6dbe485";
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
      image = "lscr.io/linuxserver/prowlarr:2.3.5@sha256:35f48abb3e976fcf077fae756866c582e4a90f8b24810ae4067b3558f7cdbbdf";
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
      image = "lscr.io/linuxserver/radarr:6.1.1@sha256:cd70546fc97169788530386b42cf47ba1b16d091b4dc2264cd54099dd13c6f7f";
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
      image = "lscr.io/linuxserver/sonarr:4.0.17@sha256:e6c9a091735fede0c2a205c69e7d4c2f0188eaf2bec7e42d8a26c017e5f2a910";
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
      image = "ghcr.io/seerr-team/seerr:v3.2.0@sha256:c4cbd5121236ac2f70a843a0b920b68a27976be57917555f1c45b08a1e6b2aad";
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
      image = "lscr.io/linuxserver/jellyfin:10.11.8@sha256:e93bc100c6da07bd058678e4b634e4e71031fe840227e2ed03a1104f032bebe8";
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
        "/var/cache/jellyfin:/cache/:rw"
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

  
}
