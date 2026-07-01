# Pi config

I use Ollama as my sole model provider. It serves both local and remote models through a single unified HTTP API running locally, allowing seamless toggling between local and cloud models.

Pi's `models.json` configuration SHOULD be maintained manually and MUST be synchronized with Ollama's "integrations" config – see instructions in the adjacent directory.

See the [Pi docs](https://pi.dev/docs/latest/models) for more details about configuring custom models.

## Current configuration

`models.json` defines three `ollama` provider models, all served locally via the Ollama OpenAI-compatible endpoint (`http://127.0.0.1:11434/v1`):

- `gemma4:31b`
- `qwen3.6:27b`
- `qwen3.6:35b`

All three are `_launch: true`, support text + image input, support reasoning, have a 262144-token context window, and set `maxTokens: 131072` (half the context window; max output tokens per response).

Note: Pi's default `maxTokens` is only 16384 if the field is omitted, which can silently truncate long responses ("Model stopped because it reached the maximum output token limit"). Always set `maxTokens` explicitly per model rather than relying on the default.

`settings.json` sets:

- `defaultProvider`: `ollama`
- `defaultModel`: `qwen3.6:35b`
- `defaultThinkingLevel`: `low`
- `theme`: `dark`
- `packages`: `npm:@ollama/pi-web-search`
