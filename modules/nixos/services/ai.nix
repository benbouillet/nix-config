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
    "gemma4-26b-instruct" = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF/resolve/main/gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf";
      hash = "sha256-73KMjgwzf9EGe5R68Abjip7yQZ5W/s7U/Sm0vwY24ww=";
    };
  };

  chatTemplateFile = pkgs.fetchurl {
    url = "https://huggingface.co/froggeric/Qwen-Fixed-Chat-Templates/resolve/main/chat_template.jinja";
    hash = "sha256-0gPzNC2Kf4R03VVWPuzjom5xshxvZnyduck7dis7+Zc=";
  };

in
{
  services.llama-swap = {
    enable = true;
    listenAddress = globals.hosts.chewie.ipv4;
    port = globals.ports.llama-swap;
    settings = {
      healthCheckTimeout = 120;
      logToStdout = "both";
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
            --parallel 1 \
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
            --ctx-size 131072 \
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
            --cache-idle-slots \
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
            --chat-template-file ${chatTemplateFile} \
            --chat-template-kwargs '{"reasoning_effort": "medium"}'
          '';
        };
        "gemma4-26b-instruct" = {
          name = "gemma4-26b-instruct";
          ttl = 3600;
          cmd = ''
            ${pkgs.lib.getExe' pkgs.llama-cpp "llama-server"} \
            --port ''${PORT} \
            -m ${modelFiles."gemma4-26b-instruct"} \
            --no-webui \
            --parallel 1 \
            --ctx-size 131072 \
            --cache-prompt \
            --cache-ram 16384 \
            --cache-idle-slots \
            --slot-prompt-similarity 0.10 \
            --n-gpu-layers 9999 \
            --flash-attn on \
            --split-mode none \
            --threads 4 \
            --threads-batch 4 \
            --kv-offload \
            --batch-size 2048 \
            --ubatch-size 512 \
            --cache-type-k "q8_0" \
            --cache-type-v "q8_0" \
            --metrics \
            --temp 1.0 \
            --top-p 0.95 \
            --top-k 64 \
            --min-p 0.0 \
            --presence-penalty 1.0 \
            --repeat-penalty 1.0 \
            --jinja \
            --chat-template-kwargs '{"enable_thinking":true}'
          '';
        };
      };
    };
  };
}
