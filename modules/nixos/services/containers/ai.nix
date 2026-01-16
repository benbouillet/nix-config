{
  username,
  lib,
  ...
}:
let
  domain = "r4clette.com";
  ports = {
    ollama = 9020;
    open-webui = 9021;
    perplexica = 9022;
  };
  aiUser = {
    name = "ai";
    UID = 930;
  };
  containersGroup = {
    name = "containers";
    GID = 993;
  };
  models_path = "/srv/models";
in
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${models_path} 2775 ${username} ${containersGroup.name} - -"
  ];

  users.users."${aiUser.name}" = {
    isSystemUser = true;
    createHome = false;
    uid = aiUser.UID;
    group = containersGroup.name;
  };

  virtualisation.oci-containers.containers = {
    "ollama" = {
      image = "ollama/ollama:0.14.2";
      ports = [
        "127.0.0.1:${toString ports.ollama}:11434"
      ];
      devices = [
        "nvidia.com/gpu=all"
      ];
      volumes = [
        "ollama:/root/.ollama:rw"
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
        "open-webui:/app/backend/data:rw"
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
  # services = {
  #   ollama = {
  #     enable = true;
  #     port = ollama_port;
  #     loadModels = [
  #       # "llama2:13b"
  #       "llama3.1:8b"
  #       # "llama3.2:3"
  #       # "codellama:13b"
  #       # "codellama:7b"
  #       # "zongwei/gemma3-translator:4b"
  #       # "qwen3:14b"
  #       # "qwen3:8b"
  #     ];
  #     syncModels = true;
  #     models = "/srv/llm";
  #     environmentVariables = {
  #       OLLAMA_KEEP_ALIVE = "10m";
  #       OLLAMA_FLASH_ATTENTION = "1";
  #       OLLAMA_KV_CACHE_TYPE = "q8_0";
  #       OLLAMA_HOST = "127.0.0.1:${toString ollama_port}";
  #     };
  #   };
  #   open-webui = {
  #     enable = true;
  #     port = openwebui_port;
  #     host = "127.0.0.1:${toString openwebui_port}";
  #     environment = {
  #       OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString ollama_port}";
  #     };
  #     stateDir = "${containersVolumesPath}/openwebui/";
  #   };
  # };
  # services.caddy.virtualHosts = {
  #   "ollama.${domain}".extraConfig = ''
  #     reverse_proxy 127.0.0.1:${toString ollama_port} {
  #       # Make Ollama see the request as local
  #       header_up Host 127.0.0.1:${toString ollama_port}
  #
  #       # Don’t leak client identity to upstream (can trigger “remote” policy)
  #       header_up -X-Forwarded-For
  #       header_up -X-Real-IP
  #       header_up -Forwarded
  #     }
  #   '';
  #   "chat.${domain}".extraConfig = ''
  #     reverse_proxy 127.0.0.1:${toString openwebui_port} {
  #       # Make Ollama see the request as local
  #       header_up Host 127.0.0.1:${toString openwebui_port}
  #
  #       # Don’t leak client identity to upstream (can trigger “remote” policy)
  #       header_up -X-Forwarded-For
  #       header_up -X-Real-IP
  #       header_up -Forwarded
  #     }
  #   '';
  # };
}
