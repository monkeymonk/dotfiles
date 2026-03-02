# Deno environment.

runtime_plugin_deno() {
    if [ -d "$HOME/.deno/bin" ]; then
        path_prepend "$HOME/.deno/bin"
    fi
}

hook_register setup runtime_plugin_deno
