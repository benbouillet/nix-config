{ globals, ... }:
{
  virtualisation.oci-containers.containers = {
    "mcp-searxng" = {
      image = "docker.io/isokoliuk/mcp-searxng:latest@sha256:7e7601e5981132ed6d199e259b0a7d4645b64c37479dbb9d4c83d1db1b052e43";
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
