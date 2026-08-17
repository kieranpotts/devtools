# The `etc` directory

The `etc` directory contains configuration files for various devtools – some of
which are cross-platform and so the same configurations can be shared between
Windows and Linux installations, for example.

On Linux, the [installer](../run/install) creates the symlinks listed below automatically (except for Windows-only apps: Sublime Merge, Windows Terminal, and WSL). On Windows, symlinks must be created manually via PowerShell – see [docs/installation.md](../docs/installation.md#create-symlinks-to-the-configuration-files) for the commands.

Contents:

- [`claude/settings.json`](./claude/settings.json): Configuration for the [Claude Code](https://claude.com/product/claude-code) AI coding assistant. Symlinked to `~/.claude/settings.json`.

- [`docker/desktop/settings-store.json`](./docker/desktop/settings-store.json): Settings for [Docker Desktop](https://www.docker.com/products/docker-desktop/). _Moved_ (not symlinked) to `~/.docker/desktop/settings-store.json` on Linux, or `%APPDATA%\Docker\settings-store.json` on Windows. ⚠️ Docker Desktop breaks when this file is symlinked, so in this case the install script overwrites the original. Synchronization must be done manually.

- [`ghostty/config.ghostty`](./ghostty/config.ghostty): Configuration for [Ghostty](https://ghostty.org/). Symlinked to `~/.config/ghostty/config.ghostty`.

- [`lazygit/config.yml`](./lazygit/config.yml): Configuration for [LazyGit](https://github.com/jesseduffield/lazygit). Symlinked to `~/.config/lazygit/config.yml`.

- [`nvim/init.vim`](./nvim/init.vim): Configuration for [Neovim](https://neovim.io/). Symlinked to `~/.config/nvim/init.vim`.

- [`ollama/config.json`](./ollama/config.json): Configuration for [Ollama](https://ollama.com/). Symlinked to `~/.ollama/config.json`.

- [`ollama/override.conf`](./ollama/override.conf): systemd drop-in for the `ollama` service, setting the VRAM-related server options documented in [`ollama/README.md`](./ollama/README.md). _Copied_ (not symlinked) to `/etc/systemd/system/ollama.service.d/override.conf`. ⚠️ Requires root, so the install script cannot place it. Install manually and re-copy after any change — see [`ollama/README.md`](./ollama/README.md#the-drop-in). Linux only.

- [`pi/settings.json`](./pi/settings.json): Configuration for [Pi](https://pi.dev/). Symlinked to `~/.pi/agent/settings.json`.

- [`qwen/settings.json`](./qwen/settings.json): Configuration for the [Qwen](https://qwen.ai/) AI coding assistant. Symlinked to `~/.qwen/settings.json`.

- [`sublime-merge/Preferences.sublime-settings`](./sublime-merge/Preferences.sublime-settings): Configuration for [Sublime Merge](https://www.sublimemerge.com/). Symlinked to `~/.config/sublime-merge/Packages/User/Preferences.sublime-settings` on Linux, or `%APPDATA%\Sublime Merge\Packages\User\Preferences.sublime-settings` on Windows.

- [`tmux/tmux.conf`](./tmux/tmux.conf): Configuration for [tmux](https://github.com/tmux/tmux). Symlinked to `~/.tmux.conf`.

- [`tmux/inc/layout`](./tmux/inc/layout): A tmux layout script that can be loaded with `Ctrl-t L`. Symlinked to `~/.tmux/layout`.

- [`vscode/settings.json`](./vscode/settings.json): User settings for [VS Code](https://code.visualstudio.com/) / [VS Codium](https://vscodium.com/). Symlinked to `~/.config/Code/User/settings.json` or `~/.config/VSCodium/User/settings.json`.

- [`vscode/keybindings.json`](./vscode/keybindings.json): Keyboard shortcuts for VS Code / VS Codium. Symlinked to `~/.config/Code/User/keybindings.json` or `~/.config/VSCodium/User/keybindings.json`.

- [`vscode/chatLanguageModels.json`](./vscode/chatLanguageModels.json): AI language model configuration for VS Code / VS Codium. Symlinked to `~/.config/Code/User/chatLanguageModels.json` or `~/.config/VSCodium/User/chatLanguageModels.json`.

- [`vscode/global.code-snippets`](./vscode/global.code-snippets): Global code snippets for VS Code / VS Codium. Symlinked to `~/.config/Code/User/snippets/global.code-snippets` or `~/.config/VSCodium/User/snippets/global.code-snippets`.

- [`wsl/.wslconfig`](./wsl/.wslconfig): Configuration for [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/). Symlinked to `C:\Users\[User]\.wslconfig`. Windows only.

- [`wt/settings.json`](./wt/settings.json): Configuration for [Windows Terminal](https://github.com/microsoft/terminal). Symlinked to `C:\Users\[User]\AppData\Local\Packages\Microsoft.WindowsTerminal_[hash]\LocalState\settings.json`. Windows only.

- [`zed/settings.json`](./zed/settings.json): User settings for the [Zed editor](https://zed.dev/). Symlinked to `~/.config/zed/settings.json`.
