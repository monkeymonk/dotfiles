# Editor preferences.

runtime_plugin_editor() {
    local _runtime_editor _runtime_has_nvim
    if has_cmd nvim; then
        _runtime_has_nvim=1
    else
        _runtime_has_nvim=0
    fi

    if [ "$_runtime_has_nvim" -eq 0 ]; then
        require_cmd vim || return 0
    fi

    _runtime_editor="vim"
    if [ -z "${SSH_CONNECTION-}" ] && [ "$_runtime_has_nvim" -eq 1 ]; then
        _runtime_editor="nvim"
    fi

    export EDITOR="$_runtime_editor"
    export VISUAL="$_runtime_editor"
    export SUDO_EDITOR="$_runtime_editor"

    if [ "$_runtime_has_nvim" -eq 1 ]; then
        export MANPAGER="nvim +Man!"
    fi

    unset _runtime_editor _runtime_has_nvim
}

hook_register setup runtime_plugin_editor
