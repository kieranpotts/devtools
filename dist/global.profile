# ==============================================================================
# The `~/.profile` file is a user-scoped startup script for interactive logins
# to all shell environments – Bash, Fish, Zsh, etc.

# This script is overridden by shell-specific profiles such as `~/.bash_profile`.
# Howvever, in my dotfiles configuration, `~/.profile` is sourced from
# `~/.bash_profile` and other shell-specific startup scripts, thus making this
# configuration available in every shell.
#
# You SHOULD NOT edit this file, as your changes here will be lost next time you
# fetch updates from the devtools repository. Instead, you MAY extend this
# script via the `~/local.profile` file.
# ==============================================================================

# Load aliases that are compatible with all POSIX-compliant shells.
if [ -f ~/devtools/dist/aliases/posix/index.sh ]; then
  . ~/devtools/dist/aliases/posix/index.sh
fi

# Load utility functions that are compatible with all POSIX-compliant shells.
if [ -f ~/devtools/dist/functions/posix/index.sh ]; then
  . ~/devtools/dist/functions/posix/index.sh
fi

# Load the user's `~/local.profile` file, which can be used to override
# anything set in this file.
if [ -f ~/local.profile ]; then
  . ~/local.profile
fi

# Add an alias to reload this profile. This alias SHOULD be overridden in
# any shell-specific profiles such as `~/.bash_profile`.
alias reload!=". ~/.profile"
