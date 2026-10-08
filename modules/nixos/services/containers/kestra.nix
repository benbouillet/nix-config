{
  lib,
  config,
  pkgs,
  globals,
  ...
}:
let
  kestraConfig = pkgs.writeText "kestra-application.yml" ''
    datasources:
      postgres:
        url: jdbc:postgresql://host.containers.internal:${toString globals.ports.postgres}/kestra
        driver-class-name: org.postgresql.Driver
        username: kestra

    kestra:
      repository:
        type: postgres
      queue:
        type: postgres
      storage:
        type: local
        local:
          base-path: /app/storage
      url: https://kestra.${globals.domain}/
  '';
in
{
  sops.secrets."services/kestra/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
    restartUnits = [ "podman-kestra.service" ];
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.services.apps.mountPoint}/kestra 2770 1000 1000 - -"
    "d /tmp/kestra-wd 2770 1000 1000 - -"
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
      user = "root";
      cmd = [
        "server"
        "standalone"
        "--config"
        "/app/confs/application.yml"
      ];
      ports = [
        "${globals.hosts.chewie.tailscale}:${toString globals.ports.kestra}:8080"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/kestra:/app/storage:rw"
        "/var/run/docker.sock:/var/run/docker.sock"
        "/tmp/kestra-wd:/tmp/kestra-wd"
        "${kestraConfig}:/app/confs/application.yml:ro"
      ];
      environmentFiles = [ config.sops.secrets."services/kestra/env".path ];
      extraOptions = [
        "--memory=2g"
        "--add-host=database:host-gateway"
      ];
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "kestra.${globals.domain}";
        policy = "one_factor";
        subject = "group:admins";
      }
    ];

    identity_providers.oidc.cors.allowed_origins = [
      "https://kestra.${globals.domain}"
    ];

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
