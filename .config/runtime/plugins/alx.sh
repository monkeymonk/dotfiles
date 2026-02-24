# alx integration.

runtime_plugin_alx() {
    if [ -d "$HOME/.local/share/alx/bin" ]; then
        path_prepend "$HOME/.local/share/alx/bin"
    fi

    command -v alx >/dev/null 2>&1 || return 0
}

runtime_hook_register bootstrap runtime_plugin_alx
