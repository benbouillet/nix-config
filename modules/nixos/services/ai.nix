{
  pkgs,
  globals,
  ...
}:
let
  modelFiles = {
    "qwen36-27b-ud-q5-K-XL-MTP" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF/resolve/main/Qwen3.6-27B-UD-Q5_K_XL.gguf";
      hash = "sha256-WjxhAzWBdU1Qf/3L8GKSFMv71You2+yA2T9uwq9E0ic=";
    };
    "qwen36-35b-a3b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF/resolve/main/Qwen3.6-35B-A3B-UD-IQ4_NL.gguf";
      hash = "sha256-DRfiVdwlehHzmO1LyNYkEtjOnKJLP84pR9li5L/tV1g=";
    };
    "gemma4-e4b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-UD-Q6_K_XL.gguf";
      hash = "sha256-+hby5/9sWsH/5ISBU0d6wiR2Mxy2YmfMyREy2l7r714=";
    };
    "qwen36-27b-q6-K-MTP" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF/resolve/main/Qwen3.6-27B-Q6_K.gguf";
      hash = "sha256-dz8b8L4FidBWzgVHaooTW1BJSj8uzD+PDE8sNZS7oC4=";
    };
  };

  chatTemplateFile = pkgs.fetchurl {
    url = "https://huggingface.co/froggeric/Qwen-Fixed-Chat-Templates/resolve/main/chat_template.jinja";
    hash = "sha256-Rkmz+j2z/aTVEXPtT/AXX95+zou8651ZXQTYYgIMl0Y=";
  };

  models = {
    "test" = {
      file = modelFiles."qwen36-27b-q6-K-MTP";
      qwenChatTemplate = true;
      ctx = 65536;
      ngl = 9999;
      flash-attn = "on";
      temp = "0.7";
      top-p = "0.8";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "1.5";
      repeat-penalty = "1.0";
      spec-type = "draft-mtp";
      spec-draft-n-max = 2;
      spec-draft-p-min = 0.75;
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      cache-type-k-draft = "q8_0";
      cache-type-v-draft = "q8_0";
      n-predict = 32768;
      reasoning-budget = 256;
      reasoning = false;
      chat-template-kwargs = "";
      kv-offload = false;
    };
    "qwen3.6-27b-instruct" = {
      file = modelFiles."qwen36-27b-ud-q5-K-XL-MTP";
      qwenChatTemplate = true;
      ctx = 65536;
      ngl = 9999;
      flash-attn = "on";
      temp = "0.7";
      top-p = "0.8";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "1.5";
      repeat-penalty = "1.0";
      spec-type = "draft-mtp";
      spec-draft-n-max = 2;
      spec-draft-p-min = 0.75;
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      cache-type-k-draft = "q4_0";
      cache-type-v-draft = "q4_0";
      n-predict = 32768;
      reasoning-budget = 256;
      reasoning = false;
      chat-template-kwargs = "";
      kv-offload = true;
    };
    "qwen3.6-27b-thinking" = {
      file = modelFiles."qwen36-27b-ud-q5-K-XL-MTP";
      qwenChatTemplate = true;
      ctx = 65536;
      ngl = 9999;
      flash-attn = "on";
      temp = "1.0";
      top-p = "0.95";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "1.5";
      repeat-penalty = "1.0";
      spec-type = "draft-mtp";
      spec-draft-n-max = 2;
      spec-draft-p-min = 0.75;
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      cache-type-k-draft = "q4_0";
      cache-type-v-draft = "q4_0";
      n-predict = 32768;
      reasoning-budget = 256;
      reasoning = true;
      chat-template-kwargs = "";
      kv-offload = true;
    };
    "qwen3.6-27b-coding" = {
      file = modelFiles."qwen36-27b-ud-q5-K-XL-MTP";
      qwenChatTemplate = true;
      ctx = 65536;
      ngl = 9999;
      flash-attn = "on";
      temp = "0.6";
      top-p = "0.95";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "0.0";
      repeat-penalty = "1.0";
      spec-type = "draft-mtp";
      spec-draft-n-max = 2;
      spec-draft-p-min = 0.75;
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      cache-type-k-draft = "q4_0";
      cache-type-v-draft = "q4_0";
      n-predict = 32768;
      reasoning-budget = 256;
      reasoning = true;
      chat-template-kwargs = "";
      kv-offload = true;
    };
    "qwen3.6-35b-a3b-instruct" = {
      file = modelFiles."qwen36-35b-a3b";
      qwenChatTemplate = true;
      ctx = 131072;
      ngl = 9999;
      flash-attn = "on";
      temp = "0.7";
      top-p = "0.8";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "1.5";
      repeat-penalty = "1.0";
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      n-predict = 32768;
      reasoning-budget = 256;
      reasoning = false;
      chat-template-kwargs = "";
      kv-offload = true;
    };
    "qwen3.6-35b-a3b-thinking" = {
      file = modelFiles."qwen36-35b-a3b";
      qwenChatTemplate = true;
      ctx = 131072;
      ngl = 9999;
      flash-attn = "on";
      temp = "1.0";
      top-p = "0.95";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "1.5";
      repeat-penalty = "1.0";
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      n-predict = 32768;
      reasoning-budget = 256;
      reasoning = true;
      chat-template-kwargs = "";
      kv-offload = true;
    };
    "qwen3.6-35b-a3b-coding" = {
      file = modelFiles."qwen36-35b-a3b";
      qwenChatTemplate = true;
      ctx = 65536;
      ngl = 9999;
      flash-attn = "on";
      temp = "0.6";
      top-p = "0.95";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "0.0";
      repeat-penalty = "1.0";
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      n-predict = 32768;
      reasoning-budget = 256;
      reasoning = true;
      chat-template-kwargs = "";
      kv-offload = true;
    };
    "gemma4-e4b-instruct" = {
      file = modelFiles."gemma4-e4b";
      ctx = 65536;
      ngl = 9999;
      flash-attn = "on";
      temp = "1.0";
      top-p = "0.95";
      top-k = "64";
      min-p = "0.0";
      presence-penalty = "1.0";
      repeat-penalty = "1.0";
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      chat-template-kwargs = "";
      kv-offload = true;
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
        "-np 1"
        "--flash-attn ${m.flash-attn}"
        "--cache-type-k ${m.cache-type-k or "q4_0"}"
        "--cache-type-v ${m.cache-type-v or "q4_0"}"
        "--jinja"
        "--split-mode none"
        "--batch-size 4096"
        "--ubatch-size 1024"
        "-t 8"
        "--fit on"
        "-ngl ${toString m.ngl}"
        "-c ${toString m.ctx}"
        "--temp ${m.temp}"
        "--top-p ${m.top-p}"
        "--top-k ${m.top-k}"
        "--min-p ${m.min-p}"
        "--presence-penalty ${m.presence-penalty}"
        "--repeat-penalty ${m.repeat-penalty}"
        "--no-mmproj-offload"
      ]
      ++ pkgs.lib.optional (
        m.chat-template-kwargs != ""
      ) "--chat-template-kwargs '${m.chat-template-kwargs}'"
      ++ pkgs.lib.optional (m ? spec-type) "--spec-type ${m.spec-type}"
      ++ pkgs.lib.optional (m ? spec-draft-n-max) "--spec-draft-n-max ${toString m.spec-draft-n-max}"
      ++ pkgs.lib.optional (m ? cache-type-k-draft) "--cache-type-k-draft ${m.cache-type-k-draft}"
      ++ pkgs.lib.optional (m ? cache-type-v-draft) "--cache-type-v-draft ${m.cache-type-v-draft}"
      ++ pkgs.lib.optional (m ? n-predict) "--n-predict ${toString m.n-predict}"
      ++ pkgs.lib.optional (m ? spec-draft-p-min) "--spec-draft-p-min ${toString m.spec-draft-p-min}"
      ++ pkgs.lib.optional (m ? reasoning-budget) "--reasoning-budget ${toString m.reasoning-budget}"
      ++ pkgs.lib.optional (m ? reasoning && m.reasoning) "--reasoning on"
      ++ pkgs.lib.optional (m ? reasoning && !m.reasoning) "--reasoning off"
      ++ pkgs.lib.optional (m ? qwenChatTemplate) "--chat-template-file ${chatTemplateFile}"
      ++ pkgs.lib.optional (m ? kv-offload && m.kv-offload) "--kv-offload"
      ++ pkgs.lib.optional (m ? kv-offload && !m.kv-offload) "--no-kv-offload"
    );
in
{
  services.llama-swap = {
    enable = true;
    listenAddress = globals.hosts.chewie.ipv4;
    port = globals.ports.llama-swap;
    settings = {
      healthCheckTimeout = 120;
      logToStdout = "both";
      models = pkgs.lib.mapAttrs (name: m: { cmd = mkCmd name m; }) models;
    };
  };
}
