{
  lib,
  ...
}:
let
  domain = "r4clette.com";
  ports = {
    steam = 8083;
    authelia = 9091;
  };
  users = {
    steam = {
      name = "steam";
      UID = 950;
    };
  };
  groups = {
    steam = {
      name = "steam";
      GID = 950;
    };
  };
  gamesVolumePath = "/srv/games";
  containersVolumesPath = "/srv/containers";
in
{
  boot.kernelModules = [ "uinput" ];
  hardware.uinput.enable = true;

  services.udev.extraRules = ''
    # uinput permissions
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    KERNEL=="event*", GROUP="input", MODE="0660"
  '';

  users.users = {
    "${users.steam.name}" = {
      isSystemUser = true;
      createHome = false;
      uid = users.steam.UID;
      group = groups.steam.name;
      extraGroups = [
        "input"
        "uinput"
      ];
    };
  };

  users.groups = {
    ${groups.steam.name} = {
      gid = groups.steam.GID;
    };
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${containersVolumesPath}/steam 2770 ${users.steam.name} ${groups.steam.name} - -"
    "d ${gamesVolumePath} 2770 ${users.steam.name} ${groups.steam.name} - -"
  ];

  services.authelia.instances."raclette".settings = {
    access_control = {
      rules = [
        {
          domain = "steam.${domain}";
          policy = "one_factor";
          subject = "group:steam";
        }
      ];
    };
  };

  networking.firewall = {
    interfaces.tailscale0 = {
      allowedTCPPorts = [
        47984
        47989
        47990
        48010
      ];
      allowedUDPPorts = [
        47998
        47999
        48000
        48002
        48010
      ];
    };
  };

  virtualisation.oci-containers.containers = {
    "steam" = {
      image = "josh5/steam-headless:latest";

      environment = {
        TZ = "Europe/Paris";
        NAME = "SteamHeadless";
        DISPLAY = ":55";
        GAMES_DIR = "/mnt/games";
        PUID = toString users.steam.UID;
        PGID = toString groups.steam.GID;
        UMASK = "000";
        USER_PASSWORD = "password";
        MODE = "primary";
        WEB_UI_MODE = "vnc";
        ENABLE_VNC_AUDIO = "true";
        PORT_NOVNC_WEB = toString ports.steam;
        ENABLE_STEAM = "true";
        STEAM_ARGS = "-silent";
        ENABLE_SUNSHINE = "true";
        SUNSHINE_USER = "ben";
        SUNSHINE_PASS = "foo";
        ENABLE_EVDEV_INPUTS = "true";
        FORCE_X11_DUMMY_CONFIG = "true";
        NVIDIA_DRIVER_CAPABILITIES = "all";
        NVIDIA_VISIBLE_DEVICES = "all";
      };
      capabilities = {
        NET_ADMIN = true;
        SYS_ADMIN = true;
        SYS_NICE = true;
      };
      devices = [
        "/dev/fuse:/dev/fuse"
        "/dev/uinput:/dev/uinput"
        "/dev/input:/dev/input"
        "nvidia.com/gpu=all"
      ];
      volumes = [
        "${containersVolumesPath}/steam:/home/default:rw"
        "${gamesVolumePath}/:/mnt/games/:rw"
        "/dev/shm:/dev/shm"
        "/dev/input:/dev/input"
      ];
      extraOptions = [
        "--network=host"
        "--ipc=host"
        "--ulimit=nofile=1024:524288"
        "--security-opt=seccomp=unconfined"
        "--security-opt=apparmor=unconfined"
        "--device-cgroup-rule=c 13:* rmw"
        "--device-cgroup-rule=c 10:* rmw"
      ];
    };
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @steam host steam.${domain}
    handle @steam {
      reverse_proxy 127.0.0.1:${toString ports.steam}
    }
  '';
}
