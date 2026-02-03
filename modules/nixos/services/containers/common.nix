{
  username,
  lib,
  config,
  pkgs,
  globals,
  ...
}:
{
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

  networking.firewall.trustedInterfaces = [ "podman0" ];

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
        unitConfig.RequiresMountsFor = globals.containersVolumesPath;
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
