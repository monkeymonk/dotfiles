# Emacs environment.

runtime_plugin_emacs() {
    if [ -d "$HOME/.config/emacs/bin" ]; then
        path_prepend "$HOME/.config/emacs/bin"
    fi
}

hook_register setup runtime_plugin_emacs
