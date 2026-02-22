# FZF configuration.

runtime_plugin_fzf() {
    require_cmd fzf || return 0

    if require_cmd fd; then
        export FZF_DEFAULT_COMMAND="${FZF_DEFAULT_COMMAND:-fd --type f}"
    fi

    if [ -n "${SHELL_FAMILY-}" ] && [ -f "$HOME/.fzf.${SHELL_FAMILY}" ]; then
        # shellcheck disable=SC1090
        . "$HOME/.fzf.${SHELL_FAMILY}"
    fi
}

runtime_hook_register post_config runtime_plugin_fzf
