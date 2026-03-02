# GHCup environment.

runtime_plugin_ghcup() {
    if [ -f "$HOME/.ghcup/env" ]; then
        # shellcheck disable=SC1090
        . "$HOME/.ghcup/env"
    fi
    if [ -d "$HOME/.ghcup/bin" ]; then
        path_prepend "$HOME/.ghcup/bin"
    fi
}

hook_register setup runtime_plugin_ghcup
