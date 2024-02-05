# ==============================================================================
# You MAY edit this file to extend the `~/.bash_profile` startup script, the
# content of which is managed via the devtools repository.
#
# Commands in this script MAY be dependent upon Bash-specific syntax and APIs.
# ==============================================================================

# Start Oh My Posh and load your preferred prompt theme. Errors are redirected
# to standard error because `oh-my-posh` is an optional dependency, so we don't
# want to assume it is installed.
# https://ohmyposh.dev/
eval "$(oh-my-posh init bash --config ~/devtools/etc/oh-my-posh/themes/kp2024.omp.json 2> /dev/null)"
