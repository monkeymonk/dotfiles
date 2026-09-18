# cmdx — catalog + completion for self-written scripts.

runtime_plugin_cmdx() {
    # Interactive shells only: `init` emits completion code and nothing else.
    case ${-:-} in
    *i*) ;;
    *) return 0 ;;
    esac

    has_cmd cmdx || return 0

    # Only bash and zsh are supported by `cmdx init`.
    case "${SHELL_FAMILY-}" in
    bash | zsh) ;;
    *) return 0 ;;
    esac

    # zsh registration needs compinit to have run; oh-my-zsh does that before
    # bootstrap.sh is sourced, and this runs in the last phase regardless.
    eval "$(cmdx init "$SHELL_FAMILY")"
}

hook_register interactive runtime_plugin_cmdx
