# Composer environment.

runtime_plugin_composer() {
    if [ -d "$HOME/.config/composer/vendor/bin" ]; then
        path_prepend "$HOME/.config/composer/vendor/bin"
    fi
}

runtime_hook_register post_config runtime_plugin_composer
