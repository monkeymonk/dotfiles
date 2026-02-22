# PNPM environment.

runtime_plugin_pnpm() {
    if [ -d "$HOME/.local/share/pnpm" ] || has_cmd pnpm; then
        export PNPM_HOME="$HOME/.local/share/pnpm"
        if [ -d "$PNPM_HOME" ]; then
            path_prepend "$PNPM_HOME"
        fi
    fi
}

runtime_hook_register post_config runtime_plugin_pnpm
