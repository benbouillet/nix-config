{
  pkgs,
  globals,
  lib,
  ...
}:
let
  aiModels = {
    "qwen35-35b-a3b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.5-35B-A3B-GGUF/resolve/main/Qwen3.5-35B-A3B-UD-Q4_K_XL.gguf";
      hash = "sha256-GwrGN9+gkru6J5OXfblIWkDE+LQt9f40LwB21htmroM=";
    };
    "qwen35-27b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.5-27B-GGUF/resolve/main/Qwen3.5-27B-Q3_K_S.gguf";
      hash = "sha256-TaZBV9g+3obM4bfDVLplMhgcrhWKeRMkzfOFXsDfaR8=";
    };
  };
in
{
  services.llama-cpp = {
    enable = true;
    host = "0.0.0.0";
    port = globals.ports.llama-cpp;
    modelsPreset = {
      "qwen3.5-35b-a3b" = {
        model = aiModels."qwen35-35b-a3b";
        alias = "unsloth/qwen3.5-35b-a3b";
        ctx-size = "65536";
        fit = "on";
        seed = "3407";
        temp = "0.6";
        top-p = "0.95";
        min-p = "0.0";
        top-k = "20";
        jinja = "on";
      };
      "qwen3.5-27b" = {
        model = aiModels."qwen35-27b";
        alias = "unsloth/qwen3.5-27b";

        # --- Memory & GPU ---
        ctx-size = "4096";
        n-gpu-layers = "9999";
        flash-attn = "on";
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";

        # --- Sampling (Unsloth thinking mode / precise coding) ---
        temp = "0.6";
        top-p = "0.95";
        top-k = "20";
        min-p = "0.0";
        repeat-penalty = "1.0";

        # --- Determinism ---
        seed = "3407";

        # --- Template ---
        jinja = "on";

        # --- Misc ---
        fit = "on";
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
