# Ollama config

I use Ollama as the model manager for both local and
[cloud](https://docs.ollama.com/cloud) models. The local `ollama` service
runs an HTTP server that serves both local and hosted models, ie. it acts
as a proxy for Ollama Cloud's public HTTP API. This means agents need to
connect only to the local Ollama API server, and they can switch between both
local and cloud models seamlessly. It also means I need only to configure a
single model provider – Ollama – in agents like Pi or OpenCode. I manage my
library of models from the model manager, not from the agent harness.

The Ollama API is compatible with OpenAI's API, so any front-end that supports
OpenAI's API should work with Ollama. You need only to configure the API
endpoint to point to your local Ollama server (or directly to the Ollama
cloud API if you're using only cloud models.)

## Harness configuration

Run `ollama` and follow the instructions to configure your chosen harness. For
example, to configure Pi, go to **Launch Pi** → **Select model**.

Alternatively, use `ollama launch`.

```sh
ollama launch claude --model <model>
```

Using Ollama's harness launcher will update Ollama's own `config.json` and also
Pi's `models.json`. However, it clobbers the symlinks I use to keep my devtool
configurations under version control. For this reason, I prefer to manage my
Ollama and Pi settings manually.

The Ollama and Pi model configs should be kept synchronized.

## Managing VRAM

See my [Ollama cheats](https://github.com/kieranpotts/cheats/tree/latest/dev/src/ollama)
for guidance on VRAM tuning.

This section records the settings on my workstation, and their rationale.

### The hardware

I have one discrete AMD GPU running under ROCm, plus an integrated GPU that
Ollama already ignores. The following figures are reported by the server at
load time.

* Discrete GPU: `ROCm0`, `0000:03:00.0`, 32624 MiB total
* Usable VRAM budget: ~31.3 GiB (Ollama's `available`, after its 457 MiB minimum)
* System RAM: 30.5 GiB, typically ~19 GiB free

The system RAM figure is the constraint that's easy to miss. Ollama sizes
against free memory, not total. With ~19 GiB free there is no useful CPU-offload
fallback here. A model that doesn't fit in VRAM won't run slowly… it will hit
swap. So I treat "fits entirely in VRAM" as a hard requirement rather than a
performance goal.

### The drop-in

The settings live in [`override.conf`](./override.conf), installed manually
using the following shell script.

```sh
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo cp etc/ollama/override.conf /etc/systemd/system/ollama.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

### Rationale

**`OLLAMA_CONTEXT_LENGTH=32768`.** The KV cache costs 256 KiB/token at f16 on
this hardware. A load at `n_ctx_slot = 4096` reserves exactly 1024 MiB of
context, so 32k costs 8 GiB at f16, or ~4 GiB (half) at `q8_0`.

~32 GB VRAM breaks down into ~31.3 GiB usable VRAM plus ~1.1 GiB of compute
buffers. That leaves room for a model up to ~24 GB on disk. (Ollama's own guidance
is to allow at least 64000 tokens for agentic, coding, and web-search work.)

64k doesn't fit the 30B-class models here, so 32768 is the compromise. That's
not a big enough window for long-context work, so that must be done on the cloud.

~32 GB VRAM puts the card in Ollama's 24–48 GiB band, so 32768 is also what the
server would pick unaided, anyway.

**`OLLAMA_NUM_PARALLEL=1`.** Fixed at exactly one model execution at a time.
The purpose is to avoid out-of-memory conditions. This can easily happen when
VRAM is tight and multiple models are running in parallel, because KV cache is
allocated as `num_ctx × num_parallel`. The `OLLAMA_CONTEXT_LENGTH` value
calculated above does not account for parallel execution of models. If we
did not pin `OLLAMA_RUN_PARALLEL` to 1, the server may auto-select 4, which
would mean that a 32768 context length becomes a request of 131,072 tokens
for KV.

**`OLLAMA_KV_CACHE_TYPE=q8_0`.** `q8_0` halves the size of the KV cache at
near-lossless quality. This requires flash attention, and where the architecture
or runtime doesn't support that, Ollama will silently fall back to f16 — which
would mean that KV size would be double.

**`OLLAMA_MAX_LOADED_MODELS=1`.** One 32 GiB card holds one 30B-class model.
With 30.5 GiB of RAM the page cache cannot hold two ~20 GB model files, so every
model switch is a real disk read.

**`OLLAMA_FLASH_ATTENTION` — deliberately unset.** Since Ollama 0.31.2 this is
a tri-state override, not an opt-in switch. Unset it means "auto-enable wherever
the runtime and device support it". Forcing `1` has caused quality regressions
on ROCm specifically.

**`ROCR_VISIBLE_DEVICES` — deliberately unset.** Ollama enumerates only
`ROCm0` at `0000:03:00.0`. The integrated GPU is already excluded.

### What fits at 32k

Budget: ~31.3 GiB usable, less ~1.1 GiB compute buffers, less ~4 GiB KV at
32k/`q8_0` (~8 GiB if it falls back to f16) — so roughly **26 GiB for weights**,
or ~22 GiB in the f16 fallback case. Against the on-disk sizes:

| Model                                            | On disk | 32k @ `q8_0`                |
| ------------------------------------------------ | ------- | --------------------------- |
| `nemotron-3-nano:30b`                            | 24 GB   | ⚠️ tight (~29 GiB measured) |
| `qwen3.6:35b`                                    | 23 GB   | ✅                          |
| `glm-4.7-flash`, `deepseek-r1:32b`, `gemma4:31b` | 19 GB   | ✅                          |
| `gemma4:26b`, `qwen3.6:27b`                      | 17 GB   | ✅                          |
| `magistral:24b`                                  | 14 GB   | ✅                          |
| `gpt-oss:20b`, `gpt-oss-safeguard:20b`           | 13 GB   | ✅                          |
| everything smaller                               | ≤9 GB   | ✅                          |

After any change, run `ollama ps` and confirm the model shows "100% GPU" (a
CPU split means it doesn't fit) and the expected context length. For the full
picture, `journalctl -u ollama | grep memory_breakdown_print` prints the exact
`model + context + compute` split the server actually reserved.

> [!WARNING]
> A harness's declared context window MUST be ≤ the server's real `num_ctx`,
> else history will be silently discarded. The drop-in sets **32768**, matching
> Pi's `models.json` `contextWindow`. Keep the two in step if either changes.
> See the Pi README.

## Configured models

The following models all configured for integration with Pi. They are all
reasoning/thinking models. Context is the model's native maximum. Locally,
every model's context will be capped to Ollama's `num_ctx` setting.

### Local models

| Model                                                                       | Params                           | In       | Native ctx        | Role / notes                                                                       |
| --------------------------------------------------------------------------- | -------------------------------- | -------- | ----------------- | ---------------------------------------------------------------------------------- |
| [`deepseek-r1`](https://ollama.com/library/deepseek-r1) `:8b` `:14b` `:32b` | dense                            | text     | 128K              | Reasoning-first: math, code, logic.                                                |
| [`gemma4`](https://ollama.com/library/gemma4) `:12b`                        | dense 12B                        | text+img | 256K              | Multimodal general-purpose; native tools.                                          |
| [`gemma4`](https://ollama.com/library/gemma4) `:26b`                        | MoE 25B / 3.8B active            | text+img | 256K              | Sparse multimodal; more capable, still light.                                      |
| [`gemma4`](https://ollama.com/library/gemma4) `:31b`                        | dense 30.7B                      | text+img | 256K              | Largest dense Gemma.                                                               |
| [`glm-4.7-flash`](https://ollama.com/library/glm-4.7-flash)                 | MoE 30B / A3B                    | text     | 198K              | Strong 30B-class generalist.                                                       |
| [`gpt-oss`](https://ollama.com/library/gpt-oss) `:20b`                      | MoE / 3.6B active                | text     | 128K              | Agentic: function calls, browsing, python; configurable reasoning effort.          |
| [`gpt-oss-safeguard`](https://ollama.com/library/gpt-oss-safeguard) `:20b`  | MoE / 3.6B active                | text     | 128K              | Policy/content classification (Trust & Safety), not general chat.                  |
| [`magistral`](https://ollama.com/library/magistral) `:24b`                  | dense 24B                        | text     | 128K (≤40K rec.)  | Transparent, multilingual reasoning.                                               |
| [`nemotron-3-nano`](https://ollama.com/library/nemotron-3-nano) `:4b`       | dense 4B                         | text     | 256K              | Efficient small agentic model; native tools.                                       |
| [`nemotron-3-nano`](https://ollama.com/library/nemotron-3-nano) `:30b`      | hybrid Mamba-2 MoE / 3.5B active | text     | 1M                | Efficient long-context agentic; native tools.                                      |
| [`qwen3.6`](https://ollama.com/library/qwen3.6) `:27b` `:35b`               | dense                            | text+img | 256K              | Agentic coding with thinking preservation.                                         |

### Cloud models

Cloud models are offloaded to Ollama's servers rather than run locally, so
local VRAM and the `num_ctx` cap above do not apply to them.

| Model                                                                  | Params                  | In       | Native ctx | Role / notes                                                                                                      |
| ---------------------------------------------------------------------- | ----------------------- | -------- | ---------- | ----------------------------------------------------------------------------------------------------------------- |
| [`glm-5.2`](https://ollama.com/library/glm-5.2) `:cloud`               | MoE ~750B / ~40B active | text     | ~1M        | Z.ai flagship. Long-horizon coding and agentic work; thinking effort selectable (high/max). MIT.                  |
| [`kimi-k2.7-code`](https://ollama.com/library/kimi-k2.7-code) `:cloud` | MoE ~1T / 32B active    | text+img | 256K       | Moonshot AI coding specialist. End-to-end SWE workflows, multi-step tool calls, reasoning preserved across turns. |
