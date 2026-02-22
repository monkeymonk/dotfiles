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

runtime_hook_register post_config runtime_plugin_ghcup
