# Declarative configuration: user defaults, environment exports, and
# context-derived values. Loaded after core/context.sh so RUNTIME_OS etc.
# are available for conditional exports below.

# User preference defaults.
TMUX_AUTO_ATTACH="${TMUX_AUTO_ATTACH:-1}"

# Locale & pager.
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LESS="-R"

# XDG base dirs (values set in core/env.sh — just ensure they're exported).
export XDG_CONFIG_HOME
export XDG_DATA_HOME
export XDG_CACHE_HOME

# Context-derived exports.
case "${RUNTIME_OS-}" in
    mac) export CLI_OPEN_CMD="open" ;;
    linux) export CLI_OPEN_CMD="xdg-open" ;;
esac

if [ "${RUNTIME_DISTRO-}" = "arch" ]; then
    export CLI_PKG_MGR="pacman"
fi
