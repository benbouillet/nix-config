{
  lib,
  globals,
  ...
}:
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.paths.models} 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.paths.containersVolumes}/ollama 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.paths.containersVolumes}/open-webui 2770 root ${globals.groups.containers.name} - -"
  ];

  virtualisation.oci-containers.containers = {
    "ollama" = {
      image = "ollama/ollama:0.16.1";
      ports = [
        "127.0.0.1:${toString globals.ports.ollama}:11434"
      ];
      devices = [
        "nvidia.com/gpu=all"
      ];
      volumes = [
        "${globals.paths.containersVolumes}/ollama/:/root/.ollama/:rw"
        "${globals.paths.models}:/usr/share/ollama/.ollama/models:rw"
      ];
      environment = {
        OLLAMA_MODELS = "/usr/share/ollama/.ollama/models";
        OLLAMA_KEEP_ALIVE = "10m";
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
      };
    };
    "open-webui" = {
      image = "ghcr.io/open-webui/open-webui:v0.8.1-slim";
      ports = [
        "127.0.0.1:${toString globals.ports.open-webui}:8080"
      ];
      volumes = [
        "${globals.paths.containersVolumes}/open-webui:/app/backend/data:rw"
      ];
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @ollama host ollama.${globals.domain}
    handle @ollama {
      reverse_proxy 127.0.0.1:${toString globals.ports.ollama}
    }

    @open-webui host chat.${globals.domain}
    handle @open-webui {
      reverse_proxy 127.0.0.1:${toString globals.ports.open-webui}
    }
  '';
}
