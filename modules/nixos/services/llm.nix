{
  lib,
  ...
}:
let
  domain = "r4clette.com";
  port = 11434;
in
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d /srv/llm/ 2775 ollama ollama - -"
  ];

  services.ollama = {
    enable = true;
    port = port;
    loadModels = [
      # "llama2:13b"
      "llama3.1:8b"
      # "llama3.2:3"
      # "codellama:13b"
      # "codellama:7b"
      # "zongwei/gemma3-translator:4b"
      # "qwen3:14b"
      # "qwen3:8b"
    ];
    syncModels = true;
    models = "/srv/llm";
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "10m";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_HOST = "127.0.0.1:${toString port}";
    };
  };

  services.caddy.virtualHosts."ollama.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port} {
      # Make Ollama see the request as local
      header_up Host 127.0.0.1:${toString port}

      # Don’t leak client identity to upstream (can trigger “remote” policy)
      header_up -X-Forwarded-For
      header_up -X-Real-IP
      header_up -Forwarded
    }
  '';
}
