# Deno environment.

runtime_plugin_deno() {
    if [ -d "$HOME/.deno/bin" ]; then
        path_prepend "$HOME/.deno/bin"
    fi
}

runtime_hook_register post_config runtime_plugin_deno
