# LM Studio environment.

runtime_plugin_lm_studio() {
    if [ -d "$HOME/.cache/lm-studio/bin" ]; then
        path_prepend "$HOME/.cache/lm-studio/bin"
    fi
}

hook_register setup runtime_plugin_lm_studio
