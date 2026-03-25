{
  globals,
  ...
}:
{
  services.llama-cpp = {
    enable = true;
    host = "0.0.0.0";
    port = globals.ports.llama-cpp;
    modelsDir = globals.modelsDir;
    modelsPreset = {
      "Qwen3-Coder-Next" = {
        hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
        hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
        alias = "unsloth/Qwen3-Coder-Next";
        fit = "on";
        seed = "3407";
        temp = "1.0";
        top-p = "0.95";
        min-p = "0.01";
        top-k = "40";
        jinja = "on";
      };
    };
  };
}
