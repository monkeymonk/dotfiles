# workmux integration — git worktrees + tmux for parallel agents.

runtime_plugin_workmux() {
    require_cmd workmux || return 0

    # Shell completions (bash/zsh emit sourceable output).
    case "$SHELL_FAMILY" in
        zsh|bash)
            # shellcheck disable=SC1090
            eval "$(workmux completions "$SHELL_FAMILY" 2>/dev/null)" || true
            ;;
    esac

    runtime_workmux_aliases() {
        guard_double_load RUNTIME_WORKMUX_ALIASES_LOADED || return 0

        alias wx='workmux' \
            --desc "workmux (git worktrees + tmux)" --tags "workmux,tmux,git,worktree,agent"
        alias wxa='workmux add' \
            --desc "Create worktree + tmux window" --tags "workmux,worktree,add"
        alias wxd='workmux dashboard' \
            --desc "Agent status dashboard" --tags "workmux,dashboard,agent"
        alias wxl='workmux ls' \
            --desc "List worktrees" --tags "workmux,worktree,list"
    }

    command -v alx >/dev/null 2>&1 && runtime_workmux_aliases
}

hook_register interactive runtime_plugin_workmux
