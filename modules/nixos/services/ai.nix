{
  pkgs,
  globals,
  lib,
  ...
}:
let
  aiModels = {
    "qwen35-35B-A3B" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.5-35B-A3B-GGUF/resolve/main/Qwen3.5-35B-A3B-UD-Q4_K_XL.gguf";
      hash = "sha256-GwrGN9+gkru6J5OXfblIWkDE+LQt9f40LwB21htmroM=";
    };
  };
in
{
  services.llama-cpp = {
    enable = true;
    host = "0.0.0.0";
    port = globals.ports.llama-cpp;
    modelsPreset = {
      "Qwen3.5-35B-A3B" = {
        # hf-repo = "unsloth/Qwen3.5-35B-A3B-GGUF";
        # hf-file = "Qwen3.5-35B-A3B-UD-Q4_K_XL.gguf";
        model = aiModels."qwen35-35B-A3B";
        alias = "unsloth/Qwen3.5-35B-A3B";
        ctx-size = "65536";
        fit = "on";
        seed = "3407";
        temp = "0.6";
        top-p = "0.95";
        min-p = "0.0";
        top-k = "20";
        jinja = "on";
      };
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkBefore ''
    @llama-cpp host llama-cpp.${globals.domain}
    handle @llama-cpp {
      reverse_proxy 127.0.0.1:${toString globals.ports.llama-cpp}
    }
  '';
}
