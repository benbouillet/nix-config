{ globals, ... }:
{
  virtualisation.oci-containers.containers = {
    "mcp-searxng" = {
      image = "docker.io/isokoliuk/mcp-searxng:latest@sha256:787626c360cc00559093416bc701bf029075615da0c67b7026e6bc11c7386f19";
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
