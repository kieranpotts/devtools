# Continue configuration

Configuration for the [Continue](https://www.continue.dev/) AI coding assistant (the VS Code / JetBrains extension), backed entirely by [Ollama](https://ollama.com/).

See the [Continue config reference](https://docs.continue.dev/reference) for the full schema.

## Profiles

There are two per-machine variants. The [installer](../../run/install) symlinks the one matching its `--profile` argument to `~/.continue/config.yaml`:

| Profile | File | Install command | Backend |
|---|---|---|---|
| `default` | [`config.default.yaml`](./config.default.yaml) | `./run/install` | Ollama Cloud models, with autocomplete + embeddings kept local |
| `workstation` | [`config.workstation.yaml`](./config.workstation.yaml) | `./run/install --profile workstation` | Local Ollama models (GPU) |

The cloud-backed config is the default because it works on any machine; the all-local `workstation` profile is opt-in for machines with a GPU big enough to run the large models locally.

Two configs are needed rather than one because Continue selects the `autocomplete`, `apply`, and `embed` models *silently* – autocomplete fires on every keystroke and indexing uses the embed model automatically – so they can't be switched from the UI per session the way `chat` can. The machine-appropriate defaults therefore have to be baked into separate files.

## Model roles

Continue lets a different model serve each *role*. Both profiles assign one model per role, sized to that role's quality-versus-latency trade-off, rather than using a single model for everything.

| Role | Why it gets the model it does |
|---|---|
| `chat` | Open-ended conversation where quality matters more than latency. Benefits from a large, general-purpose model with broad knowledge and reasoning depth. |
| `edit` / `apply` | Interactive editing, and applying diffs to existing code based on instructions. Needs to be capable enough to produce correct diffs, while fast enough to keep the edit–feedback loop tight. |
| `autocomplete` | Inline completions streamed as you type. Fires on every keystroke, so latency is the hard constraint. Ideal model is very small but trained and fine-tuned primarily on code – so fast _and_ quality domain-specific output A `-base` (non-instruct) variant is preferred because raw text continuation (FIM) suits completion better than chat-tuned instructions. |
| `embed` | Only vector embeddings are required for codebase indexing and semantic search. Text generation not required for this use case. A small, purpose-built embedding model is the right tool. |

An `Autodetect` entry (`model: AUTODETECT`) is also declared in both profiles. This exposes every other model available to the local Ollama install for manual selection in the UI, without each model needing to be declared explicitly. Its `roles` are scoped to `chat` deliberately: an entry with no `roles` defaults to `[chat, edit, apply, summarize]`, which would let every autodetected model claim the silently selected `edit`/`apply` roles and undercut the deliberate per-role models above.

## Default profile

The default profile assumes no local GPU, so the heavy models/roles are served from [Ollama Cloud](https://docs.ollama.com/cloud). Cloud models use the same `ollama` provider and base URL as local ones – the `-cloud` (or `:cloud`) tag routes the request through the local Ollama proxy out to Ollama's cloud. This requires being signed in (`ollama signin`).

| Role | Model | Local or cloud |
|---|---|---|
| `chat` | `gemma4:31b-cloud` | ☁️ Cloud |
| `edit`, `apply` | `qwen3.5:cloud` | ☁️ Cloud |
| `autocomplete` | `qwen2.5-coder:1.5b-base` | 💻 Local |
| `embed` | `nomic-embed-text:latest` | 💻 Local |

Autocomplete and embeddings stay local even in this profile. Both models are small enough to run comfortably on CPU, and keeping them local avoids a network round-trip on the two latency-critical paths – completions on every keystroke, and embedding every file during indexing – where cloud latency would hurt most. For `edit`/`apply`, by contrast, cloud latency is network-bound regardless of model size, so a more capable coder model is used rather than the smaller, faster local model the workstation profile can afford.

## Workstation profile

The opt-in `workstation` profile assumes a GPU, so every model runs locally.

| Role | Model | Local or cloud | Notes |
|---|---|---|---|
| `chat` | `gemma4:31b` | 💻 Local | ~30B params – reasoning depth and knowledge breadth. |
| `edit`, `apply` | `llama3.1:8b` | 💻 Local | ~8B is the sweet spot: fast diffs without sacrificing correctness. |
| `autocomplete` | `qwen2.5-coder:1.5b-base` | 💻 Local | ~1.5B code model; returns suggestions fast enough to feel instant. |
| `embed` | `nomic-embed-text:latest` | 💻 Local | Purpose-built embedding model; embeds many files cheaply. |

## Pulling the models

Continue does not download models; Ollama does. On each machine, pull the models its profile references before first use:

```sh
# Default profile – only the two local models need pulling; the cloud
# models are reached via `ollama signin` rather than `ollama pull`.
ollama pull qwen2.5-coder:1.5b-base
ollama pull nomic-embed-text

# Workstation profile – pull everything locally.
ollama pull gemma4:31b
ollama pull llama3.1:8b
ollama pull qwen2.5-coder:1.5b-base
ollama pull nomic-embed-text
```
