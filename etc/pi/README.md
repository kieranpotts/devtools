# Pi config

I use Ollama as my sole model provider. It serves both local and remote models through a single unified HTTP API running locally, allowing seamless toggling between local and cloud models.

Pi's `models.json` configuration SHOULD be maintained manually and MUST be synchronized with Ollama's "integrations" config – see instructions in the adjacent directory.

See the [Pi docs](https://pi.dev/docs/latest/models) for more details about configuring custom models.

## Current configuration

`models.json` defines the `ollama` provider models, all served locally via the Ollama OpenAI-compatible endpoint (`http://127.0.0.1:11434/v1`).

All are reasoning/thinking models with support for tools.

### maxTokens

Pi's default `maxTokens` is only 16384 if the field is omitted, which can truncate long responses ("Model stopped because it reached the maximum output token limit"). Always set it explicitly. It is capped at 8192 here so a single verbose reasoning turn cannot dominate the (small, local) context window.

### Context window alignment

My workstation's GPU has ~32 GB VRAM, so Ollama's VRAM-based default `num_ctx` is **32768** (the 24–48 GB tier). `contextWindow` is therefore set to 32768 to match. This SHOULD NOT be raised without first raising Ollama's `num_ctx` AND confirming the larger context still fits in VRAM via `ollama ps` (want "100% GPU" — CPU offload means it doesn't fit). At ~32 GB, 64k+ context will offload the 27–35B models to CPU and tank throughput.

Diagnose truncation with `ollama ps` (shows the live context length) or the Ollama journal (`memory_seq_rm` entries mark tokens being evicted).

### Longer-running sessions

Session length comes from auto-compaction. When context fills, Pi summarizes older messages and continues. `settings.json` sizes this for the 32768 window (defaults of `reserveTokens: 16384` + keepRecentTokens:
20000` overflow a 32k window):

- `compaction.enabled`: `true`
- `compaction.reserveTokens`: `8192`: Headroom for the response; compaction triggers at `contextWindow - reserveTokens` (= 24576).
- `compaction.keepRecentTokens`: `14000`: Recent work kept verbatim through each compaction; older content is summarized.

### Other settings.json values

- `defaultProvider`: `ollama`
- `defaultModel`: `qwen3.6:35b`
- `defaultThinkingLevel`: `low`
- `theme`: `dark`
- `packages`: `npm:@ollama/pi-web-search`
