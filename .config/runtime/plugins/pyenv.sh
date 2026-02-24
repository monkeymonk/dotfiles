# Pyenv environment.

runtime_plugin_pyenv() {
    [ -d "$HOME/.pyenv" ] || has_cmd pyenv || return 0

    export PYENV_ROOT="$HOME/.pyenv"
    if [ -d "$PYENV_ROOT/shims" ]; then
        path_prepend "$PYENV_ROOT/shims"
    fi
    if [ -d "$PYENV_ROOT/bin" ]; then
        path_prepend "$PYENV_ROOT/bin"
    fi

    case ${-:-} in
        *i*) ;;
        *) return 0 ;;
    esac

    command -v pyenv >/dev/null 2>&1 || return 0

    _pyenv_load() {
        eval "$(command pyenv init --path)"
        eval "$(command pyenv init -)"
    }
    lazy_load _pyenv_load pyenv python python3 pip pip3
}

runtime_hook_register setup runtime_plugin_pyenv
