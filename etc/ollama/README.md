# Ollama config

I use Ollama as the model manager for both local and [cloud](https://docs.ollama.com/cloud) models. The local `ollama` service runs an  HTTP server that serves both local and hosted models (ie. it acts as a proxy for Ollama Cloud's own public HTTP API).

This means agents need to connect only to the local Ollama API server, and they can switch between both local and cloud models seamlessly. It means I need to configure a single model provider – Ollama – in agents like Pi or OpenCode. I manage my models from the model manager, not from the agent front-end.

The Ollama API is compatible with OpenAI's API, so any front-end that supports OpenAI's API should work with Ollama – you need only to configure the API endpoint to point to your local Ollama server (or the Ollama cloud API.)

## Front-end (harness) configuration

Run `ollama` and follow the instructions to configure your front-end tool. For example, to configure Pi, go to **Launch Pi** → Select model. Ollama will update it's own `config.json` and also Pi's `models.json`. However, it clobbers the symlinks I use to keep my devtool configuration under version control. For this reason, I prefer to manage the configuration for Ollama and Pi manually.

## Model selections

My current model choices, which I run both locally and in the cloud, depending on which device I'm using, are:

- `kimi-k2.6` (default): Excellent coding model with long-horizon execution and multimodel and agent swarming capabilitities. Text + images.

- `qwen3.5`: Reasoning, coding, and agentic tool use. Text + images.

- `gemma4:31b`: Agentic workflows and multimodal reasoning. Text + images.

- `glm-5.1`: Long-horizon agentic engineering with autonomous execution and sustained iteration. Text only.

