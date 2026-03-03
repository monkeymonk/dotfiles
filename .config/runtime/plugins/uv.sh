# UV Python package manager.

runtime_plugin_uv() {
    require_cmd uv || return 0

    path_prepend "$HOME/.local/bin"
    export UV_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/uv"

    case ${-:-} in *i*)
        case "${SHELL_FAMILY-}" in
            zsh|bash) eval "$(uv generate-shell-completion "$SHELL_FAMILY")" ;;
        esac ;;
    esac
}

hook_register setup runtime_plugin_uv
