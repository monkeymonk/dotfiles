# FZF configuration.

runtime_plugin_fzf() {
    case ${-:-} in
        *i*) ;;
        *) return 0 ;;
    esac

    if [ -n "${ZSH_VERSION-}" ] && [ -n "${ZSH-}" ]; then
        _runtime_fzf_is_func=0
        case "$(type fzf 2>/dev/null)" in
            *function*) _runtime_fzf_is_func=1 ;;
        esac
        if [ "$_runtime_fzf_is_func" -eq 0 ]; then
            fzf() {
                if [ "$1" = "--zsh" ] && [ -d "$HOME/.fzf/shell" ]; then
                    [ -f "$HOME/.fzf/shell/key-bindings.zsh" ] && cat "$HOME/.fzf/shell/key-bindings.zsh"
                    [ -f "$HOME/.fzf/shell/completion.zsh" ] && cat "$HOME/.fzf/shell/completion.zsh"
                    return 0
                fi
                command fzf "$@"
            }
        fi
        unset _runtime_fzf_is_func
    fi

    require_cmd fzf || return 0

    if require_cmd fd; then
        export FZF_DEFAULT_COMMAND="${FZF_DEFAULT_COMMAND:-fd --type f}"
    fi

    if [ -n "${SHELL_FAMILY-}" ]; then
        _runtime_fzf_sourced=0
        if [ -f "$HOME/.fzf/shell/key-bindings.${SHELL_FAMILY}" ]; then
            # shellcheck disable=SC1090
            . "$HOME/.fzf/shell/key-bindings.${SHELL_FAMILY}"
            _runtime_fzf_sourced=1
        fi
        if [ -f "$HOME/.fzf/shell/completion.${SHELL_FAMILY}" ]; then
            # shellcheck disable=SC1090
            . "$HOME/.fzf/shell/completion.${SHELL_FAMILY}"
            _runtime_fzf_sourced=1
        fi
        if [ "$_runtime_fzf_sourced" -eq 0 ] && [ -f "$HOME/.fzf.${SHELL_FAMILY}" ]; then
            # shellcheck disable=SC1090
            . "$HOME/.fzf.${SHELL_FAMILY}"
        fi
        unset _runtime_fzf_sourced
    fi
}

runtime_hook_register post_context runtime_plugin_fzf
