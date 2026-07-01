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

My current model choices, and their rationale, are documented here.

### Chat models

- [**`gemma4:31b`**](https://ollama.com/library/gemma4:31b) (default):

  - local + cloud
  - 30.7B parameters (dense, not MoE)
  - 256K token context
  - multimodal: text + images
  - native tool calling
  - configurable thinking modes

  This is my default model in both Pi and Continue. It's a general-purpose model that's a good default for chat. ~30B parameter count is the sweet spot for open-ended conversation, giving the model reasoning depth and knowledge breadth, while not suffering from the latency of the largest models. Multimodal capabilities mean conversations can alternate between text and images. This is also a decent choice for mid-weight agentic tasks.

  This model is not resource-hungry, so it performs well locally on workstations with mainstream consumer GPUs. Ollama Cloud hosts the same model, which is the default on my laptop.

- [**`qwen3.5`**](https://ollama.com/library/qwen3.5):

  - local + cloud
  - variety of local model sizes from 0.8B to 122B to fit all devices…
  - … plus MLX builds for Apple Silicon and a 397B cloud model
  - 256K token context (all variants)
  - multimodal: text + images
  - native tool calling
  - thinking

  I switch to this model for probelms where the bottleneck is *thinking*, not throughput: debugging subtle logic, working through algorithms, planning an approach before code, and tool-calling chains that need each step reasoned through carefully. Multimodal input also makes this a good choice for working on diagrams and UI mock-ups, etc.

  A wide variety of model sizes are available from Ollama to download and run locally. I keep a few of those around.

### Agentic workflows

While `gemma4:31b` works fine for mid-weight agentic tasks, sustaining autonomous execution over short time periods, I turn to `glm-5.1` or `kimi-k2.6` – both cloud-only models – where I want sustained iteration over much longer horizons.

These models maintain high output quality over long sessions. They are specifically built to stay on-task over hundreds of iterations and thousands of tool calls, without hand-holding. They're overkill, though, for most day-to-day programming tasks.

- [**`glm-5.1`**](https://ollama.com/library/glm-5.1):

  - cloud only
  - ~754B parameters (MoE, ~40B active)
  - 198K token context
  - text only
  - native tool calling
  - thinking

  This model is for the longest, most autonomous tasks: large refactors, multi-step migrations, end-to-end features, that sort of thing. It has proven to keep working coherently over very long sessions without drifting, demonstrating sustainable iteration.

  The full weights are ~1.65TB, so local hosting is impractical for all but exotic setups.

- [**`kimi-k2.6`**](https://ollama.com/library/kimi-k2.6):

  - cloud only
  - ~1.04T parameters (MoE; ~32B active)
  - 256K token context
  - multimodal: text + images
  - tool use
  - extended "thinking" reasoning

  Another reliable workhorse for long-horizon agentic execution in the cloud. This model is well regarded for its strong coding capabilities and for its proven ability to run for many turns without losing the thread.

  It's not as good as `glm-5.1` for sustained iteration over very long time horizons, but what sets it apart is its swarming capabilities. This makes this model a good pick when you want to fan a problem out across parallel sub-agents.

### Utility models

These are small, special-purpose, locally-run models that back the in-editor roles in my [Continue](../continue/config.yaml) setup — applying changes, autocomplete, and embeddings.

These models are deliberately compact. The events these models respond to either fire continuously (eg. autocomplete) or run in bulk (eg. embedding a whole codebase), so latency and resource cost matter far more than for coding and agentic models.

- [**`llama3.1:8b`**](https://ollama.com/library/llama3.1)

  - 8.03B parameters (dense)
  - 128K token context
  - text only
  - tool use

  Configured for the "edit" and "apply" roles in Continue, ie. rewriting selected code from an instruction.

  The ~8B class is the sweet spot for interactive editing. The model is capable enough to produce correct diffs, and fast enough to keep the edit-feedback loop tight.

- [**`qwen2.5-coder:1.5b-base`**](https://ollama.com/library/qwen2.5-coder)

  - 1.54B parameters
  - code-specialised
  - text only

  This model is configured for the "autocomplete" (ie. inline completions) role in Continue.

  The `-base` (non-instruct) variant is required because text continuation is fill-in-the-middle, not chat-style instruction following.

  At 1.5B it returns suggestions fast enough to feel instant on every keystroke. The Qwen Coder models are fine-tuned on computer program code, so producing good quality outputs despite the small size.

- [**`nomic-embed-text:latest`**](https://ollama.com/library/nomic-embed-text)

  - ~137M parameters
  - 768-dimension embeddings
  - ~2K-token context
  - 274 MB on disk

  This is a dedicated encoder that produces embeddings only — no text generation. It is purpose-built for cheap, high-quality vector embeddings across many files, ideal for indexing codebases and semantic search.

  This model is configured for the "embed" role in Continue.
