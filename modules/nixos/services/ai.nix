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
    "qwen36-35b-a3b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/resolve/main/Qwen3.6-35B-A3B-UD-IQ4_NL_XL.gguf";
      hash = "sha256-Bx7ioAjsUTcvmQ2O++qS7J3QE3l0EQ72j7/eQpyMbdQ=";
    };
    "gemma4-e4b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-UD-Q6_K_XL.gguf";
      hash = "sha256-+hby5/9sWsH/5ISBU0d6wiR2Mxy2YmfMyREy2l7r714=";
    };
  };
in
{
  services.llama-cpp = {
    enable = true;
    host = globals.hosts.chewie.ipv4;
    port = globals.ports.llama-cpp;
    modelsPreset = {
      "qwen3.6-27b-instruct" = {
        model = aiModels."qwen36-27b";
        alias = "qwen3.6-27b-instruct";

        # --- Memory & GPU ---
        ctx-size = "131072";
        n-gpu-layers = "9999";
        flash-attn = "on";
        cache-type-k = "q4_0";
        cache-type-v = "q4_0";

        # --- Sampling (Unsloth non-thinking / instruct mode) ---
        temp = "0.7";
        top-p = "0.8";
        top-k = "20";
        min-p = "0.0";
        presence-penalty = "1.5";
        repeat-penalty = "1.0";

        # --- Template ---
        jinja = "on";
        chat-template-kwargs = "{\"enable_thinking\":false}";

        # --- Misc ---
        fit = "on";
      };
      "qwen3.6-27b-thinking" = {
        model = aiModels."qwen36-27b";
        alias = "qwen3.6-27b-thinking";

        # --- Memory & GPU ---
        ctx-size = "262144";
        n-gpu-layers = "9999";
        flash-attn = "on";
        cache-type-k = "q4_0";
        cache-type-v = "q4_0";

        # --- Sampling (Unsloth thinking mode) ---
        temp = "1.0";
        top-p = "0.95";
        top-k = "20";
        min-p = "0.0";
        presence-penalty = "1.5";
        repeat-penalty = "1.0";

        # --- Template ---
        jinja = "on";
        chat-template-kwargs = "{\"enable_thinking\":true}";

        # --- Misc ---
        fit = "on";
      };
      "qwen3.6-27b-coding" = {
        model = aiModels."qwen36-27b";
        alias = "qwen3.6-27b-coding";

        # --- Memory & GPU ---
        ctx-size = "262144";
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
      "qwen3.6-35b-a3b-instruct" = {
        model = aiModels."qwen36-35b-a3b";
        alias = "qwen3.6-35b-a3b-instruct";

        # --- Memory & GPU ---
        ctx-size = "131072";
        n-gpu-layers = "9999";
        flash-attn = "on";
        cache-type-k = "q4_0";
        cache-type-v = "q4_0";

        # --- Sampling (Unsloth non-thinking / instruct mode) ---
        temp = "0.7";
        top-p = "0.8";
        top-k = "20";
        min-p = "0.0";
        presence-penalty = "1.5";
        repeat-penalty = "1.0";

        # --- Template ---
        jinja = "on";
        chat-template-kwargs = "{\"enable_thinking\":false}";

        # --- Misc ---
        fit = "on";
      };
      "qwen3.6-35b-a3b-thinking" = {
        model = aiModels."qwen36-35b-a3b";
        alias = "qwen3.6-35b-a3b-thinking";

        # --- Memory & GPU ---
        ctx-size = "262144";
        n-gpu-layers = "9999";
        flash-attn = "on";
        cache-type-k = "q4_0";
        cache-type-v = "q4_0";

        # --- Sampling (Unsloth thinking mode) ---
        temp = "1.0";
        top-p = "0.95";
        top-k = "20";
        min-p = "0.0";
        presence-penalty = "1.5";
        repeat-penalty = "1.0";

        # --- Template ---
        jinja = "on";
        chat-template-kwargs = "{\"enable_thinking\":true}";

        # --- Misc ---
        fit = "on";
      };
      "qwen3.6-35b-a3b-coding" = {
        model = aiModels."qwen36-35b-a3b";
        alias = "qwen3.6-35b-a3b-coding";

        # --- Memory & GPU ---
        ctx-size = "262144";
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
      "gemma4-e4b-instruct" = {
        model = aiModels."gemma4-e4b";
        alias = "gemma4-e4b-instruct";

        # --- Memory & GPU ---
        ctx-size = "65536";
        n-gpu-layers = "9999";
        flash-attn = "on";
        cache-type-k = "q4_0";
        cache-type-v = "q4_0";

        # --- Sampling (Google defaults for Gemma 4) ---
        temp = "1.0";
        top-p = "0.95";
        top-k = "64";
        min-p = "0.0";
        presence-penalty = "1.0";
        repeat-penalty = "1.0";

        # --- Template ---
        jinja = "on";

        # --- Misc ---
        fit = "on";
      };
    };
  };
}
