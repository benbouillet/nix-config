{
  config,
  lib,
  pkgs,
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
      image = "docker.io/qmcgaw/gluetun:v3.41.3@sha256:fa19cc76b2af13d57a8d3dc3066f2ada061b1c761b8aecf989b3877c0486e027";
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
      image = "lscr.io/linuxserver/nzbget:26.3.20260918@sha256:3b92679543623c8710fec557de7dd525d55bb5dfc8c59526f054123eaae0f995";
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
      image = "lscr.io/linuxserver/bazarr:1.6.1@sha256:d24bd0048c759a468970989e9df11a6b96a7628d556d00f923e60a35ba59237b";
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
      image = "lscr.io/linuxserver/prowlarr:2.6.5@sha256:c96b56d94d116a9f4de94bc23d3381689492e6c3cfb7435320e8d982e406f99a";
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
      image = "lscr.io/linuxserver/radarr:6.4.4@sha256:c960f2b52ec6542dbe6707c5a21e696a7c74fd8b17997454f4d10a55dacee133";
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
      image = "lscr.io/linuxserver/sonarr:4.0.20@sha256:a5c1a5fecbef946927ab90ad68df319ac5fe644057e5fc18cd993f01ac07b2b2";
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
      image = "ghcr.io/seerr-team/seerr:v3.4.1@sha256:f4768de5f616248d723e05891f3345a1402123775d03bf0890dbfedc0831bda1";
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
      image = "lscr.io/linuxserver/jellyfin:10.11.11@sha256:438e44330078e6b1a810fdec9dc0f4773e6595edb137c5eb4417a516da4c7f0e";
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
        "${pkgs.writeShellScript "jellyfin-intel-vaapi" ''
          set -euo pipefail

          device=/dev/dri/render-intel
          test -c "$device"

          major=$(stat -c '%t' "$device")
          minor_hex=$(stat -c '%T' "$device")
          test "$major" = e2
          minor=$((16#$minor_hex))
          target=/dev/dri/renderD$minor

          if [ -e "$target" ] || [ -L "$target" ]; then
            if [ -L "$target" ]; then
              if [ -e "$target" ]; then
                target_major=$(stat -c '%t' "$target")
                target_minor=$(stat -c '%T' "$target")
                test "$target_major" = "$major" -a "$target_minor" = "$minor_hex"
              else
                rm "$target"
              fi
            else
              target_major=$(stat -c '%t' "$target")
              target_minor=$(stat -c '%T' "$target")
              test "$target_major" = "$major" -a "$target_minor" = "$minor_hex"
            fi
          fi

          if [ ! -e "$target" ] && [ ! -L "$target" ]; then
            ln -s "$device" "$target"
          fi

          if [ -f /config/encoding.xml ]; then
            sed -i 's#<VaapiDevice>[^<]*</VaapiDevice>#<VaapiDevice>/dev/dri/render-intel</VaapiDevice>#' /config/encoding.xml
          fi
        ''}:/custom-cont-init.d/10-intel-vaapi:ro"
      ];
      devices = [
        "/dev/dri/render-intel:/dev/dri/render-intel:rwm"
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
