# mise — polyglot version manager (node, python, ruby, go, ...).
#
# Two integration modes:
#
#   1. Shims (always): ~/.local/share/mise/shims prepended to PATH so
#      scripts and editors resolve the right tool version without any
#      shell hook.
#
#   2. Activate (interactive): `eval "$(mise activate <shell>)"` installs
#      a chpwd-like hook that updates PATH per directory. Only run in
#      interactive shells; skipped elsewhere.

runtime_plugin_mise() {
    require_cmd mise || return 0

    # Shims: available in any shell, including non-interactive subshells.
    path_prepend "$HOME/.local/share/mise/shims"

    # Activate hook — interactive only.
    case ${-:-} in
        *i*) ;;
        *)   return 0 ;;
    esac

    local _shell
    if   [ -n "$ZSH_VERSION" ];  then _shell=zsh
    elif [ -n "$BASH_VERSION" ]; then _shell=bash
    else return 0  # unsupported shell — shims still work
    fi

    eval "$(mise activate "$_shell" 2>/dev/null)"
}

hook_register setup runtime_plugin_mise
