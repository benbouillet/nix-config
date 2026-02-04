{
  globals,
  lib,
  ...
}:
{
  boot.kernelModules = [ "uinput" ];
  hardware.uinput.enable = true;

  services.udev.extraRules = ''
    # uinput permissions
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    KERNEL=="event*", GROUP="input", MODE="0660"
  '';

  users.users = {
    "${globals.users.steam.name}" = {
      isSystemUser = true;
      createHome = false;
      uid = globals.users.steam.UID;
      group = globals.groups.steam.name;
      extraGroups = [
        "input"
        "uinput"
      ];
    };
  };

  users.groups = {
    ${globals.groups.steam.name} = {
      gid = globals.groups.steam.GID;
    };
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.paths.containersVolumes}/steam 2770 ${globals.users.steam.name} ${globals.groups.steam.name} - -"
    "d ${globals.path.games} 2770 ${globals.users.steam.name} ${globals.groups.steam.name} - -"
  ];

  services.authelia.instances."raclette".settings = {
    access_control = {
      rules = [
        {
          domain = "steam.${globals.domain}";
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
        PUID = toString globals.users.steam.UID;
        PGID = toString globals.groups.steam.GID;
        UMASK = "000";
        USER_PASSWORD = "password";
        MODE = "primary";
        WEB_UI_MODE = "vnc";
        ENABLE_VNC_AUDIO = "true";
        PORT_NOVNC_WEB = toString globals.ports.steam;
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
        "${globals.paths.containersVolumes}/steam:/home/default:rw"
        "${globals.gamesVolumePath}/:/mnt/games/:rw"
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

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @steam host steam.${globals.domain}
    handle @steam {
      reverse_proxy 127.0.0.1:${toString globals.ports.steam}
    }
  '';
}
