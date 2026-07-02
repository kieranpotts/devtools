# Pi config

I use Ollama as my sole model provider. It serves both local and remote models through a single unified HTTP API running locally, allowing seamless toggling between local and cloud models.

Pi's `models.json` configuration SHOULD be maintained manually and MUST be synchronized with Ollama's "integrations" config – see instructions in the adjacent directory.

See the [Pi docs](https://pi.dev/docs/latest/models) for more details about configuring custom models.

## Current configuration

`models.json` defines the `ollama` provider models, all served locally via the Ollama OpenAI-compatible endpoint (`http://127.0.0.1:11434/v1`).

All are reasoning/thinking models with support for tools.

### cost

Every model sets `cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }`. The Pi TUI multiplies these per-million-token rates against usage to render a running $ total.

Zero is the *correct* value here for both categories of model, not a placeholder:

- Locally-served models (everything except the `:cloud` tags) cost real money in electricity but nothing per-token — there's no API meter to report.

- The `:cloud`-tagged models (`glm-5.2:cloud`, `kimi-k2.7-code:cloud`) run on Ollama Cloud's flat subscription/quota, not per-token billing, so a per-token $ rate would misrepresent the actual cost. Usage against that quota is tracked on the Ollama account dashboard, not in Pi.

### maxTokens

Pi's default `maxTokens` is only 16384 if the field is omitted, which can truncate long responses ("Model stopped because it reached the maximum output token limit"). Always set it explicitly. It is capped at 8192 here so a single verbose reasoning turn cannot dominate the (small, local) context window.

### Context window alignment

My workstation's GPU has ~32 GB VRAM, so Ollama's VRAM-based default `num_ctx` is **32768** (the 24–48 GB tier). `contextWindow` is therefore set to 32768 for every **locally-served** model to match. This SHOULD NOT be raised without first raising Ollama's `num_ctx` AND confirming the larger context still fits in VRAM via `ollama ps` (want "100% GPU" — CPU offload means it doesn't fit). At ~32 GB, 64k+ context will offload the 27–35B models to CPU and tank throughput.

Diagnose truncation with `ollama ps` (shows the live context length) or the Ollama journal (`memory_seq_rm` entries mark tokens being evicted).

The two `:cloud`-tagged models (`glm-5.2:cloud`, `kimi-k2.7-code:cloud`) are exempt from this cap: they run on Ollama's cloud infrastructure, not local VRAM, so `contextWindow` is set to their native context length instead. `ollama pull` for a `:cloud` tag only downloads a small manifest — the weights stay remote.

Native context lengths per model, per the [Ollama library](https://ollama.com/library) (2026-07):

| Model | `contextWindow` | Native max | Note |
|---|---|---|---|
| `deepseek-r1:8b` / `:14b` / `:32b` | 32768 | 128K | Capped to VRAM tier; local. |
| `gemma4:12b` / `:26b` / `:31b` | 32768 | 256K | Capped to VRAM tier; local. |
| `glm-4.7-flash` | 32768 | ~198K | Capped to VRAM tier; local. |
| `glm-5.2:cloud` | **999424** | ~976K (~1M) | Cloud-served — set to native max, VRAM cap doesn't apply. |
| `gpt-oss:20b` / `gpt-oss-safeguard:20b` | 32768 | 128K | Capped to VRAM tier; local. |
| `kimi-k2.7-code:cloud` | **262144** | 256K | Cloud-served — set to native max, VRAM cap doesn't apply. |
| `magistral:24b` | 32768 | 128K (Mistral recommends ≤40K in practice) | Capped to VRAM tier; local. |
| `nemotron3:33b` | 32768 | 128K | Capped to VRAM tier; local. |
| `nemotron-3-nano:4b` / `:30b` | 32768 | 256K / 1M | Capped to VRAM tier; local. |
| `north-mini-code-1.0` | 32768 | 256K | Capped to VRAM tier; local. |
| `qwen3.6:27b` / `:35b` | 32768 | 256K | Capped to VRAM tier; local. |

Cloud values were rounded to the exact figures reported on each model's Ollama library page rather than the round "1M"/"256K" marketing numbers, since `contextWindow` should reflect what the API will actually honor.

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
