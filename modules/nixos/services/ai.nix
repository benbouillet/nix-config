{
  pkgs,
  globals,
  ...
}:
let
  modelFiles = {
    "qwen36-27b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF/resolve/main/Qwen3.6-27B-UD-Q5_K_XL.gguf";
      hash = "sha256-WjxhAzWBdU1Qf/3L8GKSFMv71You2+yA2T9uwq9E0ic=";
    };
    "qwen36-35b-a3b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/resolve/main/Qwen3.6-35B-A3B-UD-IQ4_NL.gguf";
      hash = "sha256-DRfiVdwlehHzmO1LyNYkEtjOnKJLP84pR9li5L/tV1g=";
    };
    "gemma4-e4b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-UD-Q6_K_XL.gguf";
      hash = "sha256-+hby5/9sWsH/5ISBU0d6wiR2Mxy2YmfMyREy2l7r714=";
    };
  };

  models = {
    "qwen3.6-27b-instruct" = {
      file = modelFiles."qwen36-27b";
      ctx = 131072;
      ngl = 9999;
      flash-attn = "on";
      temp = "0.7";
      top-p = "0.8";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "1.5";
      repeat-penalty = "1.0";
      chat-template-kwargs = ''{"enable_thinking":false}'';
    };
    "qwen3.6-27b-thinking" = {
      file = modelFiles."qwen36-27b";
      ctx = 131072;
      ngl = 9999;
      flash-attn = "on";
      temp = "1.0";
      top-p = "0.95";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "1.5";
      repeat-penalty = "1.0";
      chat-template-kwargs = ''{"enable_thinking":true}'';
    };
    "qwen3.6-27b-coding" = {
      file = modelFiles."qwen36-27b";
      ctx = 131072;
      ngl = 9999;
      flash-attn = "on";
      temp = "0.6";
      top-p = "0.95";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "0.0";
      repeat-penalty = "1.0";
      chat-template-kwargs = ''{"enable_thinking":true}'';
    };
    "qwen3.6-35b-a3b-instruct" = {
      file = modelFiles."qwen36-35b-a3b";
      ctx = 131072;
      ngl = 9999;
      flash-attn = "on";
      temp = "0.7";
      top-p = "0.8";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "1.5";
      repeat-penalty = "1.0";
      chat-template-kwargs = ''{"enable_thinking":false}'';
    };
    "qwen3.6-35b-a3b-thinking" = {
      file = modelFiles."qwen36-35b-a3b";
      ctx = 262144;
      ngl = 9999;
      flash-attn = "on";
      temp = "1.0";
      top-p = "0.95";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "1.5";
      repeat-penalty = "1.0";
      chat-template-kwargs = ''{"enable_thinking":true}'';
    };
    "qwen3.6-35b-a3b-coding" = {
      file = modelFiles."qwen36-35b-a3b";
      ctx = 262144;
      ngl = 9999;
      flash-attn = "on";
      temp = "0.6";
      top-p = "0.95";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "0.0";
      repeat-penalty = "1.0";
      chat-template-kwargs = ''{"enable_thinking":true}'';
    };
    "gemma4-e4b-instruct" = {
      file = modelFiles."gemma4-e4b";
      ctx = 65536;
      ngl = 9999;
      flash-attn = "auto";
      temp = "1.0";
      top-p = "0.95";
      top-k = "64";
      min-p = "0.0";
      presence-penalty = "1.0";
      repeat-penalty = "1.0";
      chat-template-kwargs = "";
    };
  };

  s = pkgs.lib.getExe' pkgs.llama-cpp "llama-server";
  mkCmd =
    _: m:
    pkgs.lib.concatStringsSep " " (
      [
        s
        "--port \${PORT}"
        "-m ${m.file}"
        "--no-webui"
        "--flash-attn ${m.flash-attn}"
        "--cache-type-k q4_0"
        "--cache-type-v q4_0"
        "--jinja"
        "-ngl ${toString m.ngl}"
        "-c ${toString m.ctx}"
        "--temp ${m.temp}"
        "--top-p ${m.top-p}"
        "--top-k ${m.top-k}"
        "--min-p ${m.min-p}"
        "--presence-penalty ${m.presence-penalty}"
        "--repeat-penalty ${m.repeat-penalty}"
      ]
      ++ pkgs.lib.optional (
        m.chat-template-kwargs != ""
      ) "--chat-template-kwargs '${m.chat-template-kwargs}'"
    );
in
{
  services.llama-swap = {
    enable = true;
    listenAddress = globals.hosts.chewie.ipv4;
    port = globals.ports.llama-swap;
    settings = {
      healthCheckTimeout = 120;
      models = pkgs.lib.mapAttrs (name: m: { cmd = mkCmd name m; }) models;
    };
  };
}
