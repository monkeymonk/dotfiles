# Python venv autoload.

runtime_plugin_python() {
    if [ -f "$HOME/venv/bin/activate" ]; then
        # shellcheck disable=SC1091
        . "$HOME/venv/bin/activate"
    fi
}

runtime_hook_register post_config runtime_plugin_python
