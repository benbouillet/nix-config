{
  lib,
  config,
  globals,
  ...
}:
{
  sops.secrets."services/kestra/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.services.apps.mountPoint}/kestra 2770 1000 1000 - -"
  ];

  services = {
    postgresql = {
      enable = lib.mkForce true;
      ensureDatabases = lib.mkAfter [
        "kestra"
      ];
      ensureUsers = lib.mkAfter [
        {
          name = "kestra";
          ensureDBOwnership = true;
          ensureClauses = {
            createrole = true;
            createdb = true;
            connection_limit = 20;
          };
        }
      ];
    };
  };

  virtualisation.oci-containers.containers = {
    "kestra" = {
      image = "docker.io/kestra/kestra:v2.0.4@sha256:3db5e0110babe75bdf6d9e5f030e1df9f7da2a148c47b5197ba233f3f0d6e8f5";
      ports = [
        "${globals.hosts.chewie.tailscale}:${toString globals.ports.kestra}:8080"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/kestra:/app/storage:rw"
        "/var/run/docker.sock:/var/run/docker.sock"
        "/tmp/kestra-wd:/tmp/kestra-wd"
      ];
      environmentFiles = [ config.sops.secrets."services/kestra/env".path ];
      extraOptions = [
        "--memory=2g"
        "--pids-limit=32"
        "--add-host=database:host-gateway"
      ];
    };
  };

  systemd.services."podman-kestra" = {
    after = [
      "postgresql.service"
    ];
    requires = [
      "postgresql.service"
    ];
  };

}
