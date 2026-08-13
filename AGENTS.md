# Devtools

Configurations for Kieran Potts' development tools, plus programming fonts
and Windows ports of Unix tools (`make`, `wget`, `jq`, etc., for use in
MSysGit/Git Bash). Purpose: migrating devtool configs between machines via
symlinks installed from this repo.

The capitalized words REQUIRED, MUST, MUST NOT, RECOMMENDED, SHOULD,
SHOULD NOT, OPTIONAL, and MAY are to be interpreted as described in
[IETF RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

## Tech stack

- POSIX shell (`run/install`).
- Config files for: Claude Code, Docker Desktop, Ghostty, LazyGit, Neovim,
  Pi, Qwen, Sublime Merge, tmux, VS Code/VSCodium, WSL, Windows Terminal,
  Zed.
- Windows `.exe` ports bundled in `bin/`: `delta`, `htmlq`, `jabba`, `jq`,
  `lazygit`, `make`, `oh-my-posh`, `wget`, Xpdf tools (`pdfdetach`,
  `pdffonts`, `pdfimages`, `pdfinfo`, `pdftohtml`, `pdftopng`, `pdftoppm`,
  `pdftops`, `pdftotext`).

## Project structure

- **`etc/<tool>/`** \
  Source-of-truth config files, one directory per tool. See
  [`etc/README.md`](./etc/README.md) for the full list and each file's
  install target path.

- **`bin/`** \
  Bundled Windows binaries (x86-64/amd64) for use in Git Bash.

- **`run/install`** \
  POSIX shell installer. Backs up any existing config file
  (`--no-clobber`, dereferencing symlinks), then symlinks each file under
  `etc/` to its target location (e.g. `etc/claude/settings.json` →
  `~/.claude/settings.json`). Handles Windows (`MSYS=winsymlinks:nativestrict`)
  so `ln` creates real symlinks rather than copies. Windows-only apps
  (Sublime Merge, Windows Terminal, WSL) and Docker Desktop (which breaks
  if its settings file is symlinked) require manual steps — see
  `docs/installation.md`.

- **`docs/`** \
  `requirements.md`, `installation.md`, `maintenance.md` (where to fetch
  fresh Windows binaries and fonts).

## Tools

- **`sh run/install`** to symlink all tracked configs into place (Linux;
  run from Git Bash on Windows for the applicable subset).

## Rules

- MUST update [`etc/README.md`](./etc/README.md) when adding, removing, or
  retargeting a config file under `etc/` — it is the canonical map of
  source file to install location.

- MUST add a corresponding symlink command to `run/install` for any new
  config file that should be installed automatically (Docker Desktop's
  settings file is the documented exception: it is copied, not symlinked).

## References

This project follows Kieran Potts' technical standards. Read the relevant
standard(s) below for the current task; their RFC 2119 rules MUST be
followed unless explicitly overridden elsewhere in this file.

- **[TS-9: Version Control](https://kieranpotts.com/standards/009)**
- **[TS-31: Unix Shells and POSIX Standards](https://kieranpotts.com/standards/031)**
