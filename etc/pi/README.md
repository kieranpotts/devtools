# Pi config

I use Ollama as my sole model provider. It serves both local and remote models
through a single unified HTTP API running locally, allowing seamless toggling
between local and cloud models.

Pi's `models.json` configuration SHOULD be maintained manually and MUST be
synchronized with Ollama's "integrations" config – see instructions in the
adjacent directory.

See the [Pi docs](https://pi.dev/docs/latest/models) for more details about
configuring custom models.

## Current configuration

`models.json` defines the `ollama` provider models, all served locally via the
Ollama OpenAI-compatible endpoint (`http://127.0.0.1:11434/v1`).

All are reasoning/thinking models with support for tools.

### cost

Every model sets `cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }`.
The Pi TUI multiplies these per-million-token rates against usage to render a
running $ total.

Zero is the correct value here for both cloud and local models. Locally-served
models cost real money in electricity but nothing per token. Cloud models I run
on Ollama Cloud's flat subscription quote, not per-token billing.

### maxTokens

Pi's default `maxTokens` is only 16384 if the field is omitted, which can
truncate long responses ("Model stopped because it reached the maximum output
token limit"). Always set it explicitly. It is capped at 8192 here so a single
verbose reasoning turn cannot dominate the small context window.

### Context window alignment

My workstation's GPU has ~32 GB VRAM, so Ollama's VRAM-based default `num_ctx`
is **32768** (for the 24–48 GB tier). This is also my explicit config override
— see my Ollama config in the adjacent directory.

`contextWindow` is therefore set to 32768 for every locally-served model to match.
This SHOULD NOT be raised without first raising Ollama's `num_ctx` AND confirming
the larger context still fits in VRAM via `ollama ps` (want "100% GPU" — CPU
offload means it doesn't fit).

64k+ context will offload 27–35B models to CPU, tanking throughput.

Diagnose truncation with `ollama ps` (shows the live context length) or the
Ollama journal (`memory_seq_rm` entries mark tokens being evicted).

The two `:cloud`-tagged models (`glm-5.2:cloud`, `kimi-k2.7-code:cloud`) are
exempt from this cap, since they run on Ollama's cloud infrastructure. Their
`contextWindow` is set to their native context length, instead.

Native context lengths per model, per the [Ollama library](https://ollama.com/library) (2026-07):

| Model                                   | `contextWindow` | Native max  | Note                                                      |
|-----------------------------------------|-----------------|-------------|-----------------------------------------------------------|
| `deepseek-r1:8b` / `:14b` / `:32b`      | 32768           | 128K        | Capped to VRAM tier; local.                               |
| `gemma4:12b` / `:26b` / `:31b`          | 32768           | 256K        | Capped to VRAM tier; local.                               |
| `glm-4.7-flash`                         | 32768           | ~198K       | Capped to VRAM tier; local.                               |
| `glm-5.2:cloud`                         | 999424          | ~976K (~1M) | Cloud-served — set to native max, VRAM cap doesn't apply. |
| `gpt-oss:20b` / `gpt-oss-safeguard:20b` | 32768           | 128K        | Capped to VRAM tier; local.                               |
| `kimi-k2.7-code:cloud`                  | 262144          | 256K        | Cloud-served — set to native max, VRAM cap doesn't apply. |
| `magistral:24b`                         | 32768           | 128K (*)    | Capped to VRAM tier; local.                               |
| `nemotron-3-nano:4b` / `:30b`           | 32768           | 256K / 1M   | Capped to VRAM tier; local.                               |
| `qwen3.6:27b` / `:35b`                  | 32768           | 256K        | Capped to VRAM tier; local.                               |

(*) Mistral recommends ≤40K in practice.

### Longer-running sessions

When the context window fills, Pi automatically triggers compaction, which
involves summarizing older messages to reduce current context length.

The following settings control Pi's compaction globally. The `reserveTokens`
setting compacts early, before the context window is blown, to leave some
headroom for new response output. The `keepRecentTokens` stops the most recent
context from being compacts — only older messages are summarized.

- `compaction.enabled`: `true`

- `compaction.reserveTokens`: `8192`: Headroom for the response. Compaction
  triggers at `contextWindow - reserveTokens`. For example, if a model's
  `contextWindow` is 32768, the compaction will happen at 32768 - 8192 = 24576.

- `compaction.keepRecentTokens`: `14000`: Recent work kept verbatim through
  each compaction.

These settings have been deliberately reduced from Pi's defaults, which are
`reserveTokens: 16384` and `keepRecentTokens: 20000`. The sum of these two
settings overflows a 32k window. You want to keep the sum well below the
minimum context window you have available for your models.
