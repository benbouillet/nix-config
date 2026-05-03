{
  pkgs,
  globals,
  ...
}:
let
  aiModels = {
    "qwen36-27b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/Qwen3.6-27B-UD-Q4_K_XL.gguf";
      hash = "sha256-/2lB3tUls06xWUlnYsKd0Oxucdwxt01X512HGgPuwlk=";
    };
  };
in
{
  services.llama-cpp = {
    enable = true;
    host = globals.hosts.chewie.ipv4;
    port = globals.ports.llama-cpp;
    modelsPreset = {
      "qwen3.5-27b" = {
        model = aiModels."qwen36-27b";
        alias = "qwen3.6-27b-coding";

        # --- Memory & GPU ---
        ctx-size = "131072";
        n-gpu-layers = "9999";
        flash-attn = "on";
        cache-type-k = "q4_0";
        cache-type-v = "q4_0";

        # --- Sampling (Unsloth thinking mode / precise coding) ---
        temp = "0.6";
        top-p = "0.95";
        top-k = "20";
        min-p = "0.0";
        presence-penalty = "0.0";
        repeat-penalty = "1.0";

        # --- Template ---
        jinja = "on";
        chat-template-kwargs = "{\"enable_thinking\":true}";

        # --- Misc ---
        fit = "on";
      };
    };
  };
}
