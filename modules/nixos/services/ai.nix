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
    "gemma-4-26b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF/resolve/main/gemma-4-26B-A4B-it-UD-Q3_K_M.gguf";
      hash = "sha256-YI38q9D8l2fviFmpqHZcCYQKwAwG3sKqHerZ8GcoMk0=";
    };
  };
in
{
  services.llama-cpp = {
    enable = true;
    host = globals.hosts.chewie.ipv4;
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
      "gemma-4-26b" = {
        model = aiModels."gemma-4-26b";
        alias = "unsloth/gemma-4-26b";

        # --- Memory & GPU ---
        ctx-size = "16384";
        n-gpu-layers = "9999";
        flash-attn = "on";
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";

        # --- Sampling (Gemma 4 default) ---
        temp = "1.0";
        top-p = "0.95";
        top-k = "64";
        min-p = "0.0";
        repeat-penalty = "1.0";

        # --- Determinism ---
        seed = "3407";

        # --- Template ---
        jinja = "on";
        chat-template-kwargs = "'{\"enable_thinking\":true}'";

        # --- Misc ---
        fit = "on";
      };
    };
  };
}
