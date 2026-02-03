{
  lib,
  globals,
  ...
}:
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.modelsPath} 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.containersVolumesPath}/ollama 2770 root ${globals.groups.containers.name} - -"
    "d ${globals.containersVolumesPath}/open-webui 2770 root ${globals.groups.containers.name} - -"
  ];

  virtualisation.oci-containers.containers = {
    "ollama" = {
      image = "ollama/ollama:0.15.4";
      ports = [
        "127.0.0.1:${toString globals.ports.ollama}:11434"
      ];
      devices = [
        "nvidia.com/gpu=all"
      ];
      volumes = [
        "${globals.containersVolumesPath}/ollama/:/root/.ollama/:rw"
        "${globals.modelsPath}:/usr/share/ollama/.ollama/models:rw"
      ];
      environment = {
        OLLAMA_MODELS = "/usr/share/ollama/.ollama/models";
        OLLAMA_KEEP_ALIVE = "10m";
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
      };
    };
    "open-webui" = {
      image = "ghcr.io/open-webui/open-webui:v0.7.2-slim";
      ports = [
        "127.0.0.1:${toString globals.ports.open-webui}:8080"
      ];
      volumes = [
        "${globals.containersVolumesPath}/open-webui:/app/backend/data:rw"
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
