{ globals, ... }:
{
  virtualisation.oci-containers.containers = {
    "mcp-searxng" = {
      image = "docker.io/isokoliuk/mcp-searxng:latest";
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
