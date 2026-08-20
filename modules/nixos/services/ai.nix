{
  pkgs,
  globals,
  ...
}:
let
  modelFiles = {
    "qwen38-27b-ud-q4-k-xl" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.8-27B-GGUF/resolve/main/Qwen3.8-27B-UD-Q4_K_XL.gguf";
      hash = "sha256-PyJweQA63SURQ35bHpSBLjYzhSJb9qm0ewBUpyvIsB4=";
    };
    "gemma4-e4b" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-UD-Q6_K_XL.gguf";
      hash = "sha256-+hby5/9sWsH/5ISBU0d6wiR2Mxy2YmfMyREy2l7r714=";
    };
  };

  chatTemplateFile = pkgs.fetchurl {
    url = "https://huggingface.co/froggeric/Qwen-Fixed-Chat-Templates/resolve/main/chat_template.jinja";
    hash = "sha256-0gPzNC2Kf4R03VVWPuzjom5xshxvZnyduck7dis7+Zc=";
  };

  models = {
    "qwen3.8-27b-thinking" = {
      file = modelFiles."qwen38-27b-ud-q4-k-xl";
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
      reasoning = true;
      chat-template-kwargs = "";
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
      ++ pkgs.lib.optional (m ? "cpu-moe" && m."cpu-moe") "--cpu-moe"
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
      # models = pkgs.lib.mapAttrs (name: m: { cmd = mkCmd name m; }) models;
      models = {
        "qwen3.8:27b" = {
          name = "qwen3.8:27b";
          ttl = 3600;
          cmd = ''
            ${pkgs.lib.getExe' pkgs.llama-cpp "llama-server"} \
            --port ''${PORT} \
            -m ${modelFiles."qwen38-27b-ud-q4-k-xl"} \
          ''
          # --- runtime ---
          + ''
            --no-webui \
            --parallel 2 \
            --kv-unified \
          ''
          # --- offload / compute ---
          + ''
            --n-gpu-layers 9999 \
            --flash-attn on \
            --split-mode none \
            --threads 4 \
            --threads-batch 4 \
            --kv-offload \
          ''
          # --- context / batching ---
          + ''
            --ctx-size 106496 \
            --batch-size 2048 \
            --ubatch-size 512 \
          ''
          # --- kv cache ---
          + ''
            --cache-type-k "q8_0" \
            --cache-type-v "q8_0" \
          ''
          # --- prompt cache ---
          + ''
            --cache-prompt \
            --cache-ram 16384 \
            --no-cache-idle-slots \
            --slot-prompt-similarity 0.10 \
          ''
          # --- observability ---
          + ''
            --metrics \
          ''
          # --- sampling ---
          + ''
            --temp 1.0 \
            --top-p 0.95 \
            --top-k 20 \
            --min-p 0.0 \
            --presence-penalty 0.0 \
            --repeat-penalty 1.0 \
            --n-predict 8192 \
          ''
          # --- speculative decoding ---
          + ''
            --spec-type draft-mtp \
            --spec-draft-n-max 2 \
            --spec-draft-p-min 0.0 \
          ''
          # --- reasoning ---
          + ''
            --reasoning auto \
            --reasoning-budget 8192 \
          ''
          # --- chat template ---
          + ''
            --jinja \
            --chat-template-file ${chatTemplateFile}
          '';
          # Option 1: primary-context-first fallback. Use when a 128k primary context
          # matters more than running a local subagent concurrently.
          # cmd = ''
          #   ${pkgs.lib.getExe' pkgs.llama-cpp "llama-server"} \
          #   --port ''${PORT} \
          #   -m ${modelFiles."qwen38-27b-ud-q4-k-xl"} \
          #   ''
          #   # --- runtime ---
          #   + ''
          #     --no-webui \
          #     --parallel 1 \
          #   ''
          #   # --- offload / compute ---
          #   + ''
          #     --n-gpu-layers 9999 \
          #     --flash-attn on \
          #     --split-mode none \
          #     --threads 4 \
          #     --threads-batch 4 \
          #     --kv-offload \
          #   ''
          #   # --- context / batching ---
          #   + ''
          #     --ctx-size 131072 \
          #     --batch-size 2048 \
          #     --ubatch-size 512 \
          #   ''
          #   # --- kv cache ---
          #   + ''
          #     --cache-type-k "q8_0" \
          #     --cache-type-v "q8_0" \
          #   ''
          #   # --- prompt cache ---
          #   + ''
          #     --cache-prompt \
          #     --cache-ram 16384 \
          #     --cache-idle-slots \
          #     --slot-prompt-similarity 0.10 \
          #   ''
          #   # --- observability ---
          #   + ''
          #     --metrics \
          #   ''
          #   # --- sampling ---
          #   + ''
          #     --temp 1.0 \
          #     --top-p 0.95 \
          #     --top-k 20 \
          #     --min-p 0.0 \
          #     --presence-penalty 0.0 \
          #     --repeat-penalty 1.0 \
          #     --n-predict 8192 \
          #   ''
          #   # --- speculative decoding ---
          #   + ''
          #     --spec-type draft-mtp \
          #     --spec-draft-n-max 2 \
          #     --spec-draft-p-min 0.0 \
          #   ''
          #   # --- reasoning ---
          #   + ''
          #     --reasoning auto \
          #     --reasoning-budget 8192 \
          #   ''
          #   # --- chat template ---
          #   + ''
          #     --jinja \
          #     --chat-template-file ${chatTemplateFile}
          #   '';
        };
      };
    };
  };
}
