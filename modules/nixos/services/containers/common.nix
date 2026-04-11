{
  username,
  lib,
  config,
  pkgs,
  globals,
  ...
}:
{
  boot.kernel.sysctl = {
    # This to allow to bind to a non-existing IP during the boot process
    # To avoid postgres to fail binding to Tailscale interface during boot process
    "net.ipv4.ip_nonlocal_bind" = 1;
    # tailscale0 to podman0 IP forwarding
    "net.ipv4.ip_forward" = 1;
  };

  virtualisation = {
    podman = {
      enable = true;
      autoPrune = {
        enable = true;
        flags = [ "--all" ];
        dates = "weekly";
      };
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
    oci-containers.backend = "podman";
  };

  users.groups."containers" = {
    gid = globals.groups.containers.GID;
  };
  users.users.${username}.extraGroups = lib.mkAfter [
    "containers"
    "podman"
  ];

  networking.firewall.interfaces."podman0".allowedTCPPorts = [
    443
    globals.ports.postgres
    globals.ports.mysql
    globals.ports.redis
  ];

  systemd.services =
    # Creates containers mounts host folders before starting podman services
    (lib.mapAttrs' (
      name: _:
      lib.nameValuePair "podman-${name}" {
        after = [
          "zfs-mount.service"
          "systemd-tmpfiles-setup.service"
        ];
        requires = [
          "zfs-mount.service"
          "systemd-tmpfiles-setup.service"
        ];
      }
    ) config.virtualisation.oci-containers.containers)
    // {
      # OCI Containers auto-repair systemd service
      container-auto-repair = {
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
