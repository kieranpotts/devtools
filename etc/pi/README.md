# Pi config

I use Ollama as my sole model provider. It serves both local and remote models through a single unified HTTP API running locally, allowing seamless toggling between local and cloud models.

Pi's `models.json` configuration SHOULD be maintained manually and MUST be synchronized with Ollama's "integrations" config – see instructions in the adjacent directory.

See the [Pi docs](https://pi.dev/docs/latest/models) for more details about configuring custom models.
