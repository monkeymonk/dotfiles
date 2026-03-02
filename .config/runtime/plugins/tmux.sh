# Tmux integration.

runtime_tmux_aliases() {
    [ "${RUNTIME_TMUX_ALIASES_LOADED-}" = "1" ] && return 0
    RUNTIME_TMUX_ALIASES_LOADED=1
    if [ -d "$HOME/.tmuxp" ] || has_cmd tmuxp; then
        runtime_alias fux 'tmuxp load $(tmuxp ls | fzf --layout=reverse --info=inline --height=40%)' --desc "Tmuxp fuzzy search" --tags "tmux,session,search"
    fi
}

runtime_plugin_tmux() {
    require_cmd tmux || return 0

    if [ -n "${TMUX_AUTO_ATTACH-}" ] && [ -z "${TMUX-}" ]; then
        tmux new-session -A -s Default -c ~
    fi

    command -v alx >/dev/null 2>&1 && runtime_tmux_aliases
}

hook_register interactive runtime_plugin_tmux
