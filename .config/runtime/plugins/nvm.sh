# NVM environment.

runtime_plugin_nvm() {
    if [ -d "$HOME/.nvm" ] || has_cmd nvm; then
        export NVM_DIR="$HOME/.nvm"
        if [ -d "$NVM_DIR/bin" ]; then
            path_prepend "$NVM_DIR/bin"
        fi
    fi

    # Lazy loading (interactive shells only).
    case ${-:-} in
        *i*) ;;
        *) return 0 ;;
    esac

    if [ -n "${NVM_DIR-}" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
        if [ "${SHELL_FAMILY-}" = "zsh" ]; then
            _lazy_load_nvm() {
                unfunction nvm node npm npx _lazy_load_nvm 2>/dev/null
                # shellcheck disable=SC1090
                source "$NVM_DIR/nvm.sh"
            }

            nvm() { _lazy_load_nvm; nvm "$@"; }
            node() { _lazy_load_nvm; node "$@"; }
            npm() { _lazy_load_nvm; npm "$@"; }
            npx() { _lazy_load_nvm; npx "$@"; }
        elif [ "${SHELL_FAMILY-}" = "bash" ]; then
            _lazy_load_nvm() {
                unset -f nvm node npm npx _lazy_load_nvm 2>/dev/null
                # shellcheck disable=SC1090
                . "$NVM_DIR/nvm.sh"
            }

            nvm() { _lazy_load_nvm; nvm "$@"; }
            node() { _lazy_load_nvm; node "$@"; }
            npm() { _lazy_load_nvm; npm "$@"; }
            npx() { _lazy_load_nvm; npx "$@"; }
        fi
    fi
}

runtime_hook_register post_config runtime_plugin_nvm
