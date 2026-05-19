# The `etc` directory

The `etc` directory contains configuration files for various devtools – some of which are cross-platform and so the same configurations can be shared between Windows and Linux installations, for example.

On Linux, the [installer](../run/install) creates the symlinks listed below automatically (except for Windows-only apps: Sublime Merge, Windows Terminal, and WSL). On Windows, symlinks must be created manually via PowerShell – see [docs/installation.md](../docs/installation.md#create-symlinks-to-the-configuration-files) for the commands.

Contents:

- [`continue/config.yaml`](./continue/config.yaml): Configuration for the [Continue](https://www.continue.dev/) AI coding assistant. Symlinked to `~/.continue/config.yaml`.

- [`docker/desktop/settings-store.json`](./docker/desktop/settings-store.json): Settings for [Docker Desktop](https://www.docker.com/products/docker-desktop/). Symlinked to `~/.docker/desktop/settings-store.json` on Linux, or `%APPDATA%\Docker\settings-store.json` on Windows.

- [`keepassxc/keepassxc.ini`](./keepassxc/keepassxc.ini): Configuration for [KeePassXC](https://keepassxc.org/). Symlinked to `~/.config/keepassxc/keepassxc.ini`.

- [`lazygit/config.yml`](./lazygit/config.yml): Configuration for [LazyGit](https://github.com/jesseduffield/lazygit). Symlinked to `~/.config/lazygit/config.yml`.

- [`nvim/init.vim`](./nvim/init.vim): Configuration for [Neovim](https://neovim.io/). Symlinked to `~/.config/nvim/init.vim`.

- [`qwen/settings.json`](./qwen/settings.json): Configuration for the [Qwen](https://qwen.ai/) AI coding assistant. Symlinked to `~/.qwen/settings.json`.

- [`sublime-merge/Preferences.sublime-settings`](./sublime-merge/Preferences.sublime-settings): Configuration for [Sublime Merge](https://www.sublimemerge.com/). Symlinked to `~/.config/sublime-merge/Packages/User/Preferences.sublime-settings` on Linux, or `%APPDATA%\Sublime Merge\Packages\User\Preferences.sublime-settings` on Windows.

- [`tmux/tmux.conf`](./tmux/tmux.conf): Configuration for [tmux](https://github.com/tmux/tmux). Symlinked to `~/.tmux.conf`.

- [`tmux/inc/dev`](./tmux/inc/dev): A tmux layout script that can be loaded with `Ctrl-b D`. Symlinked to `~/.tmux/dev`.

- [`vscode/settings.json`](./vscode/settings.json): User settings for [VS Code](https://code.visualstudio.com/) / [VS Codium](https://vscodium.com/). Symlinked to `~/.config/Code/User/settings.json` or `~/.config/VSCodium/User/settings.json`.

- [`vscode/keybindings.json`](./vscode/keybindings.json): Keyboard shortcuts for VS Code / VS Codium. Symlinked to `~/.config/Code/User/keybindings.json` or `~/.config/VSCodium/User/keybindings.json`.

- [`vscode/chatLanguageModels.json`](./vscode/chatLanguageModels.json): AI language model configuration for VS Code / VS Codium. Symlinked to `~/.config/Code/User/chatLanguageModels.json` or `~/.config/VSCodium/User/chatLanguageModels.json`.

- [`vscode/global.code-snippets`](./vscode/global.code-snippets): Global code snippets for VS Code / VS Codium. Symlinked to `~/.config/Code/User/snippets/global.code-snippets` or `~/.config/VSCodium/User/snippets/global.code-snippets`.

- [`wsl/.wslconfig`](./wsl/.wslconfig): Configuration for [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/). Symlinked to `C:\Users\[User]\.wslconfig`. Windows only.

- [`wt/settings.json`](./wt/settings.json): Configuration for [Windows Terminal](https://github.com/microsoft/terminal). Symlinked to `C:\Users\[User]\AppData\Local\Packages\Microsoft.WindowsTerminal_[hash]\LocalState\settings.json`. Windows only.
