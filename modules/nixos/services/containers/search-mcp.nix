{ globals, ... }:
{
  virtualisation.oci-containers.containers = {
    "mcp-searxng" = {
      image = "docker.io/isokoliuk/mcp-searxng:latest@sha256:e19e276f50123dfaae990bb31a8ae62930ee466b716d70ddc16b9842b0327979";
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
