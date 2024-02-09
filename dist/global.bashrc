# ==============================================================================
# The `~/.bashrc` file is automatically loaded whenever a Bash shell is spawned
# in non-login mode (ie without the `-l` parameter).
#
# You SHOULD NOT edit this file, as your changes here will be lost next time you
# fetch updates from the devtools repository. Instead, you MAY extend this
# script via the `~/local.bashrc` file.
# ==============================================================================

# Load the user's `~/local.bashrc` file.
if [ -f ~/local.bashrc ]; then
  source ~/local.bashrc
fi
