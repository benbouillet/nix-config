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
    # "qwen35-27b-opus" = pkgs.fetchurl {
    #   url = "https://huggingface.co/Jackrong/Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-GGUF/resolve/main/Qwen3.5-27B.Q4_K_M.gguf";
    #   hash = "sha256-Uc5ntpNumLYKvE9hr3nD9e3RYQhxgYqRffVbquBtYxs=";
    # };
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
      # "qwen3.5-27b-opus" = {
      #   model = aiModels."qwen35-27b-opus";
      #   alias = "unsloth/qwen3.5-27b-opus";
      #
      #   # --- Memory & GPU ---
      #   ctx-size = "2048"; # Realistic for 16GB VRAM; see analysis below
      #   n-gpu-layers = "25"; # Try full offload first (Q4 ~15-16GB)
      #   flash-attn = "on"; # Drastically reduces KV cache VRAM usage
      #   cache-type-k = "q8_0"; # Optional: further KV cache compression
      #   cache-type-v = "q8_0"; # Optional: further KV cache compression
      #
      #   # --- Sampling ---
      #   temp = "0.6";
      #   min-p = "0.025"; # Filters low-probability junk tokens
      #   top-k = "0"; # Disable top-k; let min-p do the heavy lifting
      #   top-p = "0.95";
      #   repeat-penalty = "1.05"; # Mild repetition penalty
      #
      #   # --- Determinism ---
      #   seed = "3407";
      #
      #   # --- Template ---
      #   jinja = "on";
      #
      #   # --- Misc ---
      #   fit = "on";
      # };
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkBefore ''
    @llama-cpp host llama-cpp.${globals.domain}
    handle @llama-cpp {
      reverse_proxy 127.0.0.1:${toString globals.ports.llama-cpp}
    }
  '';
}
