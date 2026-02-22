# Bun environment.

runtime_plugin_bun() {
    if [ -d "$HOME/.bun" ] || has_cmd bun; then
        export BUN_INSTALL="$HOME/.bun"
        if [ -d "$BUN_INSTALL/bin" ]; then
            path_prepend "$BUN_INSTALL/bin"
        fi
    fi
}

runtime_hook_register post_config runtime_plugin_bun
