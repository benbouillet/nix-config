{
  username,
  lib,
  pkgs,
  ...
}:
{
  # Make sure tmpfiles has run before containers come up
  systemd.services."podman-oci-containers".after = [
    "zfs-mount.service"
    "systemd-tmpfiles-setup.service"
  ];
  systemd.services."podman-oci-containers".requires = [
    "zfs-mount.service"
    "systemd-tmpfiles-setup.service"
  ];

  virtualisation = {
    podman = {
      enable = true;
      autoPrune.enable = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
    oci-containers.backend = "podman";
  };

  users.users.${username} = {
    extraGroups = lib.mkAfter [
      "podman"
    ];
  };

  # OCI Containers auto-repair systemd service
  systemd.services.container-auto-repair = {
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

  systemd.timers.container-auto-repair = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "1min"; # run every minute
      Unit = "container-auto-repair.service";
    };
  };
}
