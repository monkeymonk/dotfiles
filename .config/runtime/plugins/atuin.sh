# Atuin — SQLite shell history with directory/session scoping and sync.

runtime_plugin_atuin() {
    # Interactive shells only.
    case ${-:-} in
    *i*) ;;
    *) return 0 ;;
    esac

    require_cmd atuin || return 0

    # Only the zsh integration is wired here.
    [ "${SHELL_FAMILY-}" = "zsh" ] || return 0

    # Define Atuin's zle widgets WITHOUT binding keys, so we own ^R and the up
    # arrow ourselves. This mirrors the fzf plugin and lets our bindings win the
    # zsh-vi-mode keybinding race (zvm rebinds keys in a deferred precmd init).
    eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"

    _atuin_bind_keys() {
        # ^R in both vi insert and command keymaps.
        bindkey -M viins '^r' _atuin_search_widget
        bindkey -M vicmd '^r' _atuin_search_widget
        # Up arrow (normal + application cursor-key modes) in both keymaps.
        bindkey -M viins '^[[A' _atuin_up_search_widget
        bindkey -M vicmd '^[[A' _atuin_up_search_widget
        bindkey -M viins '^[OA' _atuin_up_search_widget
        bindkey -M vicmd '^[OA' _atuin_up_search_widget
    }

    # zsh-vi-mode defers keybinding via precmd and overwrites ^R / up; append to
    # its after-init hook so our bindings win. Otherwise bind immediately.
    if (( ${+functions[zvm_init]} )) || [[ -n "${ZVM_VERSION-}" ]]; then
        zvm_after_init_commands+=('_atuin_bind_keys')
    else
        _atuin_bind_keys
    fi
}

hook_register interactive runtime_plugin_atuin
