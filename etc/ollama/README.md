# Ollama config

I use Ollama as the model manager for both local and
[cloud](https://docs.ollama.com/cloud) models. The local `ollama` service
runs an HTTP server that serves both local and hosted models, ie. it acts
as a proxy for Ollama Cloud's public HTTP API).

This means agents need to connect only to the local Ollama API server, and they
can switch between both local and cloud models seamlessly. It means I need to
configure a single model provider – Ollama – in agents like Pi or OpenCode.
I manage my library of models from the model manager, not from the agent
front-end.

The Ollama API is compatible with OpenAI's API, so any front-end that supports
OpenAI's API should work with Ollama. You need only to configure the API
endpoint to point to your local Ollama server (or directly to the Ollama
cloud API if you're using only cloud models.)

## Front-end (harness) configuration

Run `ollama` and follow the instructions to configure your front-end tool. For
example, to configure Pi, go to **Launch Pi** → **Select model**.

Ollama will update it's own `config.json` and also Pi's `models.json`.
However, it clobbers the symlinks I use to keep my devtool configurations
under version control. For this reason, I prefer to manage my Ollama and Pi
settings manually.

## Managing VRAM

See my [Ollama cheats](https://github.com/kieranpotts/cheats/tree/latest/dev/src/ollama)
for guidance on VRAM tuning.

This section records the settings on my workstation, and their rationale.

### The hardware

One discrete AMD GPU running under ROCm, plus an integrated GPU that Ollama
already ignores. Figures as the server itself reports them at load time:

| | |
| --- | --- |
| Discrete GPU | `ROCm0`, `0000:03:00.0`, 32624 MiB total |
| Usable VRAM budget | ~31.3 GiB (Ollama's `available`, after its 457 MiB minimum) |
| System RAM | 30.5 GiB, typically ~19 GiB free |

The system RAM figure is the constraint that's easy to miss. Ollama sizes
against **free** memory, not total, and with ~19 GiB free there is no useful
CPU-offload fallback here: a model that doesn't fit in VRAM won't run slowly,
it will hit swap. Treat "fits entirely in VRAM" as a hard requirement rather
than a performance goal.

### The drop-in

The settings live in [`override.conf`](./override.conf), installed manually
because a systemd drop-in needs root:

```sh
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo cp etc/ollama/override.conf /etc/systemd/system/ollama.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

### Why these values

**`OLLAMA_CONTEXT_LENGTH=32768`.** ~32 GB VRAM puts the card in Ollama's
24–48 GiB band, so 32768 is also what the server would pick unaided. The KV
cache costs **256 KiB/token** at f16 on this hardware — measured, not
estimated: a load at `n_ctx_slot = 4096` reserves exactly 1024 MiB of context.
So 32k costs 8 GiB at f16, or ~4 GiB at `q8_0`. Against ~31.3 GiB usable and
~1.1 GiB of compute buffers, that leaves room for any model up to ~24 GB on
disk. Ollama's own guidance is to allow **at least 64000** tokens for agentic,
coding, and web-search work; 64k doesn't fit the 30B-class models here, so
32768 is the compromise, and genuinely long-context work belongs on the cloud
models below.

**`OLLAMA_NUM_PARALLEL=1`.** The most important line, and the least obvious.
KV cache is allocated as `num_ctx × num_parallel`, the default auto-selects
4 or 1 from available memory, and the VRAM-tiered context defaults do *not*
account for it. Left unpinned, raising the context to 32768 can silently
become a request for 131,072 tokens of KV, and the only symptom is a CPU split
or a failed load.

**`OLLAMA_KV_CACHE_TYPE=q8_0`.** Halves the KV cache at near-lossless quality
— clearly preferable to `q4_0`. On this box it is load-bearing rather than a
bonus: at f16 a 24 GB model tops out around 24k, not 32k. But it requires
flash attention, and where the architecture or runtime doesn't support it,
Ollama falls back to f16 **silently** — you get a surprise CPU split rather
than an error. ROCm's coverage is patchier than CUDA's, so verify per model
rather than assuming. It also barely applies to `nemotron-3-nano:30b`, whose
Mamba-2 recurrent state isn't a conventional KV cache.

**`OLLAMA_MAX_LOADED_MODELS=1`.** One 32 GiB card holds one 30B-class model;
the default of 3× GPU count guarantees thrashing. The cost worth knowing: with
30.5 GiB of RAM the page cache cannot hold two ~20 GB model files, so every
model switch is a real disk read.

**`OLLAMA_FLASH_ATTENTION` — deliberately unset.** Since Ollama 0.31.2 this is
a tri-state override, not an opt-in switch: unset means "auto-enable wherever
the runtime and device support it". Forcing `1` has caused quality regressions
on ROCm specifically.

**`ROCR_VISIBLE_DEVICES` — deliberately unset.** Ollama enumerates only
`ROCm0` at `0000:03:00.0`. The integrated GPU is already excluded.

### What fits at 32k

Budget: ~31.3 GiB usable, less ~1.1 GiB compute buffers, less ~4 GiB KV at
32k/`q8_0` (~8 GiB if it falls back to f16) — so roughly **26 GiB for weights**,
or ~22 GiB in the f16 fallback case. Against the on-disk sizes:

| Model | On disk | 32k @ `q8_0` |
| --- | --- | --- |
| `nemotron3:33b` | 27 GB | ❌ — see below |
| `nemotron-3-nano:30b` | 24 GB | ⚠️ tight (~29 GiB measured) |
| `qwen3.6:35b` | 23 GB | ✅ |
| `glm-4.7-flash`, `deepseek-r1:32b`, `gemma4:31b` | 19 GB | ✅ |
| `gemma4:26b`, `qwen3.6:27b` | 17 GB | ✅ |
| `magistral:24b` | 14 GB | ✅ |
| `gpt-oss:20b`, `gpt-oss-safeguard:20b` | 13 GB | ✅ |
| everything smaller | ≤9 GB | ✅ |

> [!IMPORTANT]
> `nemotron3:33b` is the one model that cannot take the server-wide 32768. At
> 27 GB of weights it needs ~31 GiB even with `q8_0` KV, which exceeds the
> budget. Give it a per-model `num_ctx` via a Modelfile (a Modelfile-pinned
> `num_ctx` takes priority over `OLLAMA_CONTEXT_LENGTH`), or retire it in
> favour of `qwen3.6:35b`, which is 4 GB smaller and fits.
>
> Whichever way that is settled, Pi's `models.json` declares `contextWindow`
> **32768** for `nemotron3:33b` — so until the model is capped or dropped, that
> one entry over-declares and its history will be silently truncated.

After any change, run `ollama ps` and confirm the model shows "100% GPU" (a
CPU split means it doesn't fit) and the expected context length. For the full
picture, `journalctl -u ollama | grep memory_breakdown_print` prints the exact
`model + context + compute` split the server actually reserved.

> [!WARNING]
> A front-end's declared context window MUST be ≤ the server's real `num_ctx`,
> or history is silently discarded. The drop-in sets **32768**, matching Pi's
> `models.json` `contextWindow`. Keep the two in step if either changes. See
> the Pi README.

## Configured models

The following models are all configured for integration with Pi. They are all
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
| [`nemotron3`](https://ollama.com/library/nemotron3) `:33b`                  | dense 33B                        | text+img | 128K              | Multimodal (text/img/video/audio) enterprise Q&A, summarization, doc intelligence. |
| [`nemotron-3-nano`](https://ollama.com/library/nemotron-3-nano) `:4b`       | dense 4B                         | text     | 256K              | Efficient small agentic model; native tools.                                       |
| [`nemotron-3-nano`](https://ollama.com/library/nemotron-3-nano) `:30b`      | hybrid Mamba-2 MoE / 3.5B active | text     | 1M                | Efficient long-context agentic; native tools.                                      |
| [`qwen3.6`](https://ollama.com/library/qwen3.6) `:27b` `:35b`               | dense                            | text+img | 256K              | Agentic coding with thinking preservation.                                         |

### Cloud models

Cloud models are offloaded to Ollama's servers rather than run locally, so
local VRAM and the `num_ctx` cap above do not apply to them — these two are far
too large for any workstation. They do require an account: run `ollama signin`,
or set `OLLAMA_API_KEY` for direct API access.

| Model                                                                  | Params                  | In       | Native ctx | Role / notes                                                                                                      |
| ---------------------------------------------------------------------- | ----------------------- | -------- | ---------- | ----------------------------------------------------------------------------------------------------------------- |
| [`glm-5.2`](https://ollama.com/library/glm-5.2) `:cloud`               | MoE ~750B / ~40B active | text     | ~1M        | Z.ai flagship. Long-horizon coding and agentic work; thinking effort selectable (high/max). MIT.                  |
| [`kimi-k2.7-code`](https://ollama.com/library/kimi-k2.7-code) `:cloud` | MoE ~1T / 32B active    | text+img | 256K       | Moonshot AI coding specialist. End-to-end SWE workflows, multi-step tool calls, reasoning preserved across turns. |
