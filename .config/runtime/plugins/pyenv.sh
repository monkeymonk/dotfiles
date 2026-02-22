# Pyenv environment.

runtime_plugin_pyenv() {
    if [ -d "$HOME/.pyenv" ] || has_cmd pyenv; then
        export PYENV_ROOT="$HOME/.pyenv"
        if [ -d "$PYENV_ROOT/shims" ]; then
            path_prepend "$PYENV_ROOT/shims"
        fi
        if [ -d "$PYENV_ROOT/bin" ]; then
            path_prepend "$PYENV_ROOT/bin"
        fi
    fi

    # Lazy loading (interactive shells only).
    case ${-:-} in
        *i*) ;;
        *) return 0 ;;
    esac

    if [ -d "${PYENV_ROOT:-$HOME/.pyenv}" ] && command -v pyenv >/dev/null 2>&1; then
        if [ "${SHELL_FAMILY-}" = "zsh" ]; then
            _lazy_load_pyenv() {
                unfunction pyenv python python3 pip pip3 _lazy_load_pyenv 2>/dev/null
                eval "$(command pyenv init --path)"
                eval "$(command pyenv init -)"
            }

            pyenv() { _lazy_load_pyenv; pyenv "$@"; }
            python() { _lazy_load_pyenv; python "$@"; }
            python3() { _lazy_load_pyenv; python3 "$@"; }
            pip() { _lazy_load_pyenv; pip "$@"; }
            pip3() { _lazy_load_pyenv; pip3 "$@"; }
        elif [ "${SHELL_FAMILY-}" = "bash" ]; then
            _lazy_load_pyenv() {
                unset -f pyenv python python3 pip pip3 _lazy_load_pyenv 2>/dev/null
                eval "$(command pyenv init --path)"
                eval "$(command pyenv init -)"
            }

            pyenv() { _lazy_load_pyenv; command pyenv "$@"; }
            python() { _lazy_load_pyenv; command python "$@"; }
            python3() { _lazy_load_pyenv; command python3 "$@"; }
            pip() { _lazy_load_pyenv; command pip "$@"; }
            pip3() { _lazy_load_pyenv; command pip3 "$@"; }
        fi
    fi
}

runtime_hook_register post_config runtime_plugin_pyenv
