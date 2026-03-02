# PNPM environment.

runtime_plugin_pnpm() {
    if [ -d "$HOME/.local/share/pnpm" ] || has_cmd pnpm; then
        export PNPM_HOME="$HOME/.local/share/pnpm"
        if [ -d "$PNPM_HOME" ]; then
            path_prepend "$PNPM_HOME"
        fi
    fi
}

hook_register setup runtime_plugin_pnpm
