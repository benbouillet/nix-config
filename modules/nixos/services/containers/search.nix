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
      image = "ghcr.io/degoog-org/degoog:0.25.0@sha256:a90a6e66765b7c05ec25c7bccaef55da3fc4e52ac0108abaebef81a3f6c1b4ba";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.degoog}:4444"
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
      image = "ghcr.io/degoog-org/mcp:0.2.0@sha256:0dd8bbb8156a366bace65a7b960b4912bff99363f7f1cfe80ca8030178da5d86";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.degoog-mcp}:4443"
      ];
      extraOptions = [
        "--memory=256m"
        "--memory-swap=512m"
        "--pids-limit=64"
      ];
      environment = {
        DEGOOG_MCP_DEGOOG_URL = "http://${globals.hosts.chewie.ipv4}:${toString globals.ports.degoog}";
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
