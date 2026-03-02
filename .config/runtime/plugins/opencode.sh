# OpenCode environment.

runtime_plugin_opencode() {
    if [ -d "$HOME/.opencode/bin" ]; then
        path_prepend "$HOME/.opencode/bin"
    fi
}

hook_register setup runtime_plugin_opencode
