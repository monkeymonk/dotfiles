# Tmux integration.

runtime_plugin_tmux() {
    require_cmd tmux || return 0

    if [ -n "${TMUX_AUTO_ATTACH-}" ] && [ -z "${TMUX-}" ]; then
        tmux new-session -A -s Default -c ~
    fi
}

runtime_hook_register late runtime_plugin_tmux
