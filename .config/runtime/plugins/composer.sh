# Composer environment.

runtime_plugin_composer() {
    if [ -d "$HOME/.config/composer/vendor/bin" ]; then
        path_prepend "$HOME/.config/composer/vendor/bin"
    fi
}

hook_register setup runtime_plugin_composer
