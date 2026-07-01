# Ollama config

I use Ollama as the model manager for both local and [cloud](https://docs.ollama.com/cloud) models. The local `ollama` service runs an HTTP server that serves both local and hosted models (ie. it acts as a proxy for Ollama Cloud's public HTTP API).

This means agents need to connect only to the local Ollama API server, and they can switch between both local and cloud models seamlessly. It means I need to configure a single model provider – Ollama – in agents like Pi or OpenCode. I manage my library of models from the model manager, not from the agent front-end.

The Ollama API is compatible with OpenAI's API, so any front-end that supports OpenAI's API should work with Ollama – you need only to configure the API endpoint to point to your local Ollama server (or the Ollama cloud API.)

## Front-end (harness) configuration

Run `ollama` and follow the instructions to configure your front-end tool. For example, to configure Pi, go to **Launch Pi** → Select model. Ollama will update it's own `config.json` and also Pi's `models.json`. However, it clobbers the symlinks I use to keep my devtool configurations under version control. For this reason, I prefer to manage my Ollama and Pi settings manually.

## Context length (`num_ctx`)

Ollama decides how large a context to load each model with (`num_ctx`), independently of what any front-end requests. Its default is VRAM-based:

| VRAM      | Default `num_ctx` |
| --------- | ----------------- |
| < 24 GB   | 4,096             |
| 24–48 GB  | 32,768            |
| 48+ GB    | 262,144           |

My workstation's discrete GPU has ~32 GB VRAM, so the default is **32768**. When a front-end sends more history than `num_ctx`, Ollama silently truncates the oldest tokens, so the model quietly forgets earlier context. A front-end's declared context window MUST therefore be ≤ the real `num_ctx` (Pi's `models.json` `contextWindow` is set to 32768 to match — see the Pi README).

Override the default with the `OLLAMA_CONTEXT_LENGTH` environment variable. Note that the `ollama` **systemd service does not inherit your shell environment**, so exporting the variable in `.bashrc` has no effect on the running server — it must be set on the service:

```sh
sudo systemctl edit ollama.service
# [Service]
# Environment="OLLAMA_CONTEXT_LENGTH=32768"
sudo systemctl daemon-reload && sudo systemctl restart ollama
```

Do not raise it beyond what fits in VRAM: larger contexts grow the KV cache, and on this ~32 GB GPU anything past ~32k offloads the 27–35B models to CPU and tanks throughput. After any change, run `ollama ps` and confirm the model shows "100% GPU" (CPU offload means it doesn't fit) and the expected context length. Truncation in progress shows up in the journal as `memory_seq_rm` entries.

## Model selections

All reasoning/thinking models. Context is the model's native maximum; locally every model is capped to Ollama's `num_ctx` (32768 here — see above).

Served to Pi via the local endpoint. `qwen3.6:35b` is the Pi default.

| Model | Params | In | Native ctx | Role / notes |
| --- | --- | --- | --- | --- |
| [`deepseek-r1`](https://ollama.com/library/deepseek-r1) `:8b` `:14b` `:32b` | dense | text | 128K | Reasoning-first: math, code, logic. |
| [`gemma4:12b`](https://ollama.com/library/gemma4) | dense 12B | text+img | 256K | Multimodal general-purpose; native tools. |
| [`gemma4:26b`](https://ollama.com/library/gemma4) | MoE 25B / 3.8B active | text+img | 256K | Sparse multimodal; more capable, still light. |
| [`gemma4:31b`](https://ollama.com/library/gemma4) | dense 30.7B | text+img | 256K | Largest dense Gemma. |
| [`glm-4.7-flash`](https://ollama.com/library/glm-4.7-flash) | MoE 30B / A3B | text | 198K | Strong 30B-class generalist. |
| [`gpt-oss:20b`](https://ollama.com/library/gpt-oss) | MoE / 3.6B active | text | 128K | Agentic: function calls, browsing, python; configurable reasoning effort. |
| [`gpt-oss-safeguard:20b`](https://ollama.com/library/gpt-oss-safeguard) | MoE / 3.6B active | text | 128K | Policy/content classification (Trust & Safety), not general chat. |
| [`magistral:24b`](https://ollama.com/library/magistral) | dense 24B | text | 128K (≤40K rec.) | Transparent, multilingual reasoning. |
| [`nemotron3:33b`](https://ollama.com/library/nemotron3) | dense 33B | text+img | 128K | Multimodal (text/img/video/audio) enterprise Q&A, summarization, doc intelligence. |
| [`nemotron-3-nano:4b`](https://ollama.com/library/nemotron-3-nano) | dense 4B | text | 256K | Efficient small agentic model; native tools. |
| [`nemotron-3-nano:30b`](https://ollama.com/library/nemotron-3-nano) | hybrid Mamba-2 MoE / 3.5B active | text | 1M | Efficient long-context agentic; native tools. |
| [`north-mini-code-1.0`](https://ollama.com/library/north-mini-code-1.0) | MoE 30B / 3B active | text | 256K in / 64K out | Cohere agentic software-engineering model; interleaved thinking. |
| [`qwen3.6`](https://ollama.com/library/qwen3.6) `:27b` `:35b` | dense | text+img | 256K | Agentic coding with thinking preservation; **`:35b` is the Pi default**. |
