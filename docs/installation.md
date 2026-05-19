# Installation

To install these devtools on a new machine, first clone the repository to the host machine.

```
git clone git@github.com:<user_or_org>/devtools.git
```

If using Windows with WSL2, the devtools should be cloned to the host (Windows) not the guest OS (WSL2).

Then follow the steps below to set up everything.

#### 1. Install the fonts.

Some devtools configurations depend on the following fonts being installed locally:

- Hack + Hack NF
- Maple Mono + Maple Mono NF (nerd font)

TrueType files for these fonts are included in the `./vendor/fonts` directory. These need to be installed manually. In Ubuntu-based Linux distributions, you can simply copy them into `~/.local/share/fonts`. If this directory does not yet exist, you can create it.

Hack and Maple Mono are programming fonts. They add special ligatures that merge multiple consecutive characters into a single composite glyph, for example `>=` is presented as `≥` and `!=` as `≠`, improving readability. The Nerd Font versions are extended with additional glyphs that are used to create visual effects like icons and rounded corners in a shell's prompt line.

#### 2. Create symlinks to the configuration files.

Configuration files are included for various development tools, including VS Code and Windows Terminal, for easy portability between machines. To use these configurations, you will need to create symlinks to them from the filesystem locations the target programs expect them to be. To do that, run Windows Powershell in administrator mode and execute the following commands, changing the filesystem paths as required.

**Sublime Merge**
```
New-Item -ItemType SymbolicLink `
  -Path "C:\Users\[User]\AppData\Roaming\Sublime Merge\Packages\User\Preferences.sublime-settings" `
  -Target "C:\path\to\devtools\etc\sublime-merge\Preferences.sublime-settings" `
  -Force
```

**VS Code / VS Codium on Windows**
```
New-Item -ItemType SymbolicLink `
  -Path "C:\Users\[User]\AppData\Roaming\[Code|VSCodium]\User\settings.json" `
  -Target "C:\path\to\devtools\etc\vscode\settings.json" `
  -Force

New-Item -ItemType SymbolicLink `
  -Path "C:\Users\[User]\AppData\Roaming\[Code|VSCodium]\User\keybindings.json" `
  -Target "C:\path\to\devtools\etc\vscode\keybindings.json" `
  -Force

New-Item -ItemType SymbolicLink `
  -Path "C:\Users\[User]\AppData\Roaming\[Code|VSCodium]\User\chatLanguageModels.json" `
  -Target "C:\path\to\devtools\etc\vscode\chatLanguageModels.json" `
  -Force

New-Item -ItemType SymbolicLink `
  -Path "C:\Users\[User]\AppData\Roaming\[Code|VSCodium]\User\snippets\global.code-snippets" `
  -Target "C:\path\to\devtools\etc\vscode\global.code-snippets" `
  -Force
```

**VS Code / VS Codium on Linux**
```
# Run these commands from the root directory of this repository.

ln --symbolic --force "${PWD}/etc/vscode/settings.json" ~/.config/[Code|VSCodium]/User/settings.json
ln --symbolic --force "${PWD}/etc/vscode/keybindings.json" ~/.config/[Code|VSCodium]/User/keybindings.json
ln --symbolic --force "${PWD}/etc/vscode/chatLanguageModels.json" ~/.config/[Code|VSCodium]/User/chatLanguageModels.json
ln --symbolic --force "${PWD}/etc/vscode/global.code-snippets" ~/.config/[Code|VSCodium]/User/snippets/global.code-snippets
```

**Windows Subsystem for Linux**
```
New-Item -ItemType SymbolicLink `
  -Path "C:\Users\[User]\.wslconfig" `
  -Target "C:\path\to\devtools\etc\wsl\.wslconfig" `
  -Force
```

**Windows Terminal**
```
New-Item -ItemType SymbolicLink `
  -Path "C:\Users\[User]\AppData\Local\Packages\Microsoft.WindowsTerminal_[hash]\LocalState\settings.json" `
  -Target "C:\path\to\devtools\etc\wt\settings.json" `
  -Force
```

**AI tools on Linux**
```
ln --symbolic --force "${PWD}/etc/continue/config.yaml" ~/.continue/config.yaml
ln --symbolic --force "${PWD}/etc/qwen/settings.json" ~/.qwen/settings.json
```

The KeePassXC configuration file can either be symlinked or imported manually.

**KeePassXC on Linux**
```
ln --symbolic --force "${PWD}/etc/keepassxc/keepassxc.ini" ~/.config/keepassxc/keepassxc.ini
```

#### 3. Add the `bin` directory to your PATH environment variable.

Windows binaries for various programs are bundled in the `bin` directory of this repository. These programs can be installed on your Windows machine simply by adding this repository's `bin` directory to your system's `PATH` environment variable.

> **Note:** The `delta`, `lazygit`, `oh-my-posh` binaries are required for my [dotfiles](https://github.com/kieranpotts/dotfiles) configuration to work in Git Bash for Windows. For WSL2 and other Unix environments, the equivalent packages can be installed using my [bootstrap](https://github.com/kieranpotts/bootstrap) scripts.

#### 4. Sync VS Code settings with GitHub Codespaces.

Optionally, you can use GitHub Settings Sync to have a consistent user experience between cloud and local instances of VS Code. You will need to login to VS Code using your GitHub account, and enable Settings Sync in your VS Code user settings. Then go to your [GitHub Codespaces options](https://github.com/settings/codespaces) and enable the Settings Sync opion there, too:

![](./_/github-enable-settings-sync.png)
