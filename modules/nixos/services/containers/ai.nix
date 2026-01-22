{
  lib,
  ...
}:
let
  domain = "r4clette.com";
  ports = {
    ollama = 9020;
    open-webui = 9021;
  };
  containersGroup = {
    name = "containers";
    GID = 993;
  };
  models_path = "/srv/models";
  containersVolumesPath = "/srv/containers";
in
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${models_path} 2770 root ${containersGroup.name} - -"
    "d ${containersVolumesPath}/ollama 2770 root ${containersGroup.name} - -"
    "d ${containersVolumesPath}/open-webui 2770 root ${containersGroup.name} - -"
  ];

  virtualisation.oci-containers.containers = {
    "ollama" = {
      image = "ollama/ollama:0.14.3";
      ports = [
        "127.0.0.1:${toString ports.ollama}:11434"
      ];
      devices = [
        "nvidia.com/gpu=all"
      ];
      volumes = [
        "${containersVolumesPath}/ollama/:/root/.ollama/:rw"
        "${models_path}:/usr/share/ollama/.ollama/models:rw"
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
        "127.0.0.1:${toString ports.open-webui}:8080"
      ];
      volumes = [
        "${containersVolumesPath}/open-webui:/app/backend/data:rw"
      ];
    };
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @ollama host ollama.${domain}
    handle @ollama {
      reverse_proxy 127.0.0.1:${toString ports.ollama}
    }

    @open-webui host chat.${domain}
    handle @open-webui {
      reverse_proxy 127.0.0.1:${toString ports.open-webui}
    }
  '';
}
