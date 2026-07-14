{ globals, ... }:
{
  virtualisation.oci-containers.containers = {
    "mcp-searxng" = {
      image = "docker.io/isokoliuk/mcp-searxng:latest@sha256:b6727fc950cf1a7501d70f863b563d9fc689d6e33c773296ed845070c5646b48";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.searxng-mcp}:3000"
      ];
      environment = {
        SEARXNG_URL = "http://${globals.hosts.chewie.ipv4}:${toString globals.ports.searxng}";
        MCP_HTTP_PORT = "3000";
      };
      extraOptions = [
        "--memory=256m"
        "--memory-swap=512m"
        "--pids-limit=64"
      ];
    };
  };
}
