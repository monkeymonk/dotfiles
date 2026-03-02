# NVM environment.

runtime_plugin_nvm() {
    [ -d "$HOME/.nvm" ] || has_cmd nvm || return 0

    export NVM_DIR="$HOME/.nvm"
    if [ -d "$NVM_DIR/bin" ]; then
        path_prepend "$NVM_DIR/bin"
    fi

    case ${-:-} in
        *i*) ;;
        *) return 0 ;;
    esac

    [ -s "$NVM_DIR/nvm.sh" ] || return 0

    _nvm_load() { . "$NVM_DIR/nvm.sh"; }
    lazy_load _nvm_load nvm node npm npx
}

hook_register setup runtime_plugin_nvm
