# llama-server KV Cache & Multi-Agent Inference

Findings on how llama.cpp's `llama-server` manages the KV cache when a multi-agent
setup (primary + subagents, e.g. opencode) hits a single model served via llama-swap.

## Decision (active configuration)

**Option 2 is active** in `modules/nixos/services/ai.nix` for `qwen3.8:27b`:

- `--parallel 2` — one primary slot + one local subagent slot, concurrently.
- `--kv-unified` — one shared KV pool across both slots.
- `--ctx-size 106496` — the **single total shared pool**: 64k primary + 32k one local
  subagent + 8k buffer. There is **no KV-per-slot multiplication**.
- `ttl = 0` keeps the `llama-server` process (and weights) resident.

Option 1 (`parallel=1`, 128k total context) was **not** selected because running a
local subagent concurrently was worth more than the primary's full 128k headroom. It
is retained as a commented fallback block immediately after the active cmd — see
"Option 1 fallback" below.

## Correct current unified-KV accounting

With `--kv-unified`, `--ctx-size` is the **single shared KV pool**, not a per-slot
context. Each slot can temporarily address the pool, but combined live use of all
slots must stay ≤ the total. The older `ctx × N` / `weights + ctx × N × cache` claim
below was wrong for unified mode and is corrected throughout this document.

- Explicit `--parallel N` requires an explicit `--kv-unified`. Unified KV is only
  automatically enabled in `parallel=-1` / auto-slot mode.
- `GET /slots` reports each slot's current `n_ctx` *within* the shared pool; the sum
  of live slot contexts is the real consumption that must stay under `--ctx-size`.

## Weights vs KV cache

- **Weights**: loaded once per `llama-server` process; shared by every request from
  every agent. No per-request load/unload happens inside llama.cpp.
- **KV cache**: per-request, per-slot state, allocated and discarded continuously.
  With unified KV it is drawn from one shared pool, so one slot's growth evicts KV in
  the other.
- **llama-swap** sits above this: it manages *processes*, not KV. A weight reload only
  happens if llama-swap stops the process (idle TTL, a swap, or a manual/API unload).
  `ttl: 0` prevents that.

## What multi-agent looks like on the wire

- Each agent *turn* = one request to `/completion` (or `/chat/completions`).
- Each *subagent* = a fresh conversation = a fresh prompt (its own system prompt +
  the task brief), unrelated to the primary's or any sibling's history.
- Multi-agent is invisible to the server except as: more requests, non-shared
  prompts, and bursts of concurrent requests.

## llama-server KV management

- **Unified KV buffer**: `-kvu, --kv-unified` — one KV pool shared across all slots
  (see accounting above). Only auto-enabled in auto-slot (`parallel=-1`) mode; an
  explicit `--parallel N` needs it set explicitly.
- **Slots**: `-np, --parallel N` sets the number of concurrent sequences.
- **Prompt/prefix caching**: `--cache-prompt` + per-request `cache_prompt`. If the
  next request's prompt shares a prefix with a cached sequence, the shared prefix KV
  is reused and only the new suffix is computed.
- **Slot reuse is fuzzy**: `--slot-prompt-similarity` (default `0.10`) controls how
  similar a request's prompt must be to a slot's cached prompt before reusing it.
- **`--cache-idle-slots` (default on with cache RAM)**: on every new completion the
  server serializes and **clears ALL idle GPU slots**. With unified KV this defeats
  resident primary KV — every completion drops what another slot cached. Our active
  config therefore sets `--no-cache-idle-slots`.
- **`--cache-ram N`**: MiB of host RAM used for the KV cache pool (prompt cache).
- **`--cache-reuse N`**: minimum chunk size for KV shifting (reuse prefix KV pages
  without full recompute); requires prompt caching enabled. Not set initially.
- **Overflow**: when the shared pool fills, tokens are discarded per `n_keep`
  (default `0`); `--context-shift` (default **disabled**) controls shift+recompute.
- **`/slots` save/restore**: optional, requires `--slot-save-path`; persists a slot's
  KV to disk.

## Slot behavior and cache-idle-slots (selected option)

- `--cache-idle-slots` is **default-on** with cache RAM. With unified KV it serializes
  and clears **ALL** idle GPU slots on every new completion — the opposite of what a
  resident primary needs.
- We disable it with `--no-cache-idle-slots` so an idle primary can remain KV-resident
  in GPU while the 32k subagent uses the other slot.
- Caveat: at actual pool pressure the server may still clear an idle slot to make
  room. There is **no reservation, priority, or slot-kv-quota** in llama-server; the
  next fill decides.

## Option 1 fallback (commented in `modules/nixos/services/ai.nix`)

A complete, line-by-line commented copy of the active cmd sits immediately after the
active binding, labelled "Option 1". Differences from Option 2 **only**:

- `--parallel 1`
- no `--kv-unified` (unneeded with one slot)
- `--ctx-size 131072` (128k primary)
- `--cache-idle-slots` (instead of `--no-cache-idle-slots`); keeps `--cache-prompt`,
  `--cache-ram 16384`, and `--slot-prompt-similarity 0.10`.

On a primary/subagent switch under Option 1, switching is an intentional KV
save/restore from host RAM (**not** a model-weight reload, and **not** a full prompt
re-prefill): `llama-server` saves the primary slot KV, restores the subagent slot KV
from `--cache-ram`. This is only useful when the primary's 128k context requirement
outweighs local subagent concurrency. The whole block is Nix comments, so it is inert
until uncommented.

## Model-specific memory math (derived)

Configured as **Qwen3.8-27B** (`qwen3.8:27b`), *not* a Coder variant.

- **KV bytes per token**, q8/q8 main cache:
  `16 full-attention layers × 4 KV heads × 256 head dim × (K + V)` =
  16 × 4 × 256 × 2 = **32768 bytes/token (32 KiB/token)**.
- **At `--ctx-size 106496`**: 106496 × 32768 bytes ≈ **3.25 GiB** of KV.
- **Weights (Q4)**: the Q4_K_XL GGUF is roughly **17.6 GB**.

Labeled **derived** rather than confirmed: actual startup memory must be measured on
the host before treating this headroom as safe. KV is also evicted/rewritten at pool
pressure, so the *resident* KV is usually well below the full 106496 pool.

## Tuning settings and rationale (matches active config)

- Main KV cache: `--cache-type-k q8_0` / `--cache-type-v q8_0` (large VRAM saving).
- Embedded-MTP draft cache: **F16 defaults**; the q4 draft cache flags were removed.
- `--flash-attn on`, `--kv-offload`, `--split-mode none`, `--n-gpu-layers 9999`.
- `--threads 4` + `--threads-batch 4` (host has only 4 cores).
- `--batch-size 2048` / `--ubatch-size 512`.
- Qwen thinking-family sampling: `--temp 1.0`, `--top-p 0.95`, `--top-k 20`,
  `--min-p 0.0`, `--presence-penalty 0.0`, `--repeat-penalty 1.0`.
- `--n-predict 8192` (8k output cap) and `--reasoning-budget 8192` (8k reasoning cap);
  `--reasoning auto`.
- MTP speculative: `--spec-type draft-mtp`, `--spec-draft-n-max 2`, `--spec-draft-p-min 0.0`.
- `--cache-prompt`, `--cache-ram 16384` (16 GiB), `--no-cache-idle-slots`,
  `--slot-prompt-similarity 0.10` — no `--cache-reuse` initially.
- `ttl = 0`; `--metrics` enabled.

## Limitations / benchmark plan

- There is **no server-side** priority, reservation, or per-slot KV quota. OpenCode
  must honor the 64k/32k client-side limits and must **not** dispatch more than two
  local concurrent tasks into `qwen3.8:27b`.
- On privilege: run a real load, then inspect startup memory, `GET /slots`, MTP
  acceptance logs/counters, tokens/sec, and actual VRAM. Only then decide whether to
  raise context, raise slots, or switch to asymmetric KV.
- Because `ttl = 0`, the **full model process stays loaded**; but its KV state can be
  evicted/modified at pool pressure.

## Sources

- llama.cpp server README (flag + endpoint reference):
  https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
- llama.cpp server context source (slot accounting, unified KV, cache-idle semantics):
  https://github.com/ggml-org/llama.cpp/blob/master/tools/server/server-context.cpp
- llama.cpp generic context / common source (KV sizing, shift/recompute):
  https://github.com/ggml-org/llama.cpp/blob/master/src/llama-context.cpp
  https://github.com/ggml-org/llama.cpp/blob/master/src/llama-context.h
- llama-swap configuration docs:
  https://github.com/mostlygeek/llama-swap/blob/main/docs/configuration.md
- llama-swap example config:
  https://github.com/mostlygeek/llama-swap/blob/main/config.example.yaml
- llama-swap config schema (authoritative options):
  https://github.com/mostlygeek/llama-swap/blob/main/config-schema.json

Confirmed behavior is cited above; the memory math is **derived** and the current
model has **not yet been load-tested** after this deployment.