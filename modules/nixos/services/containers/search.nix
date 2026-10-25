{
  config,
  globals,
  ...
}:
{
  sops.secrets."services/degoog/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/degoog 0755 1000 1000 -"
  ];

  virtualisation.oci-containers.containers = {
    "degoog" = {
      image = "ghcr.io/degoog-org/degoog:1.1.1@sha256:d0fb85d394cbb41b95c7fbf1e733ae05cbd6472cc32e614028f684613c3464b6";
      networks = [ "podman" ];
      ports = [
        "${globals.hosts.chewie.tailscale}:${toString globals.ports.degoog}:4444"
      ];
      volumes = [
        "/var/lib/degoog:/app/data"
      ];
      extraOptions = [
        "--memory=1g"
        "--memory-swap=2g"
        "--pids-limit=256"
        "--add-host=host.containers.internal:host-gateway"
      ];
      environment = {
        DEGOOG_PUBLIC_INSTANCE = "true";
        DEGOOG_DISTRUST_PROXY = "0";
        DEGOOG_VALKEY_URL = "redis://host.containers.internal:${toString globals.ports.redis}";
        PUID = "1000";
        PGID = "1000";
      };
      environmentFiles = [
        config.sops.secrets."services/degoog/env".path
      ];
    };

    "degoog-mcp" = {
      image = "ghcr.io/degoog-org/mcp:0.4.0@sha256:feb6e2dc59072232e71a92567d2b099b27af1546af0a2f039787ad635a6c19a1";
      dependsOn = [ "degoog" ];
      networks = [ "podman" ];
      ports = [
        "${globals.hosts.chewie.tailscale}:${toString globals.ports.degoog-mcp}:4443"
      ];
      extraOptions = [
        "--memory=256m"
        "--memory-swap=512m"
        "--pids-limit=64"
      ];
      environment = {
        DEGOOG_MCP_DEGOOG_URL = "http://degoog:4444";
        DEGOOG_MCP_MAX_RESULTS = "10";
        DEGOOG_MCP_SEARCH_TEXT = "results";
      };
    };
  };

  systemd.services."podman-degoog" = {
    after = [
      "postgresql.service"
      "redis-raclette.service"
    ];
  };
}
