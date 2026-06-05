# workenv integration — Dockerized portable development workspace.

_runtime_workenv_bin_dir() {
    local _home _cmd _dir

    _home="${WORKENV_HOME:-$HOME/.local/share/workenv}"
    if [ -x "$_home/bin/shellc" ] && [ -x "$_home/bin/nvimc" ] && [ -x "$_home/bin/tmuxc" ]; then
        printf '%s\n' "$_home/bin"
        return 0
    fi

    if has_cmd shellc && has_cmd nvimc && has_cmd tmuxc; then
        _cmd=$(command -v shellc 2>/dev/null) || return 1
        _dir=${_cmd%/*}
        [ -x "$_dir/nvimc" ] && [ -x "$_dir/tmuxc" ] || return 1
        printf '%s\n' "$_dir"
        return 0
    fi

    return 1
}

runtime_workenv_aliases() {
    guard_double_load RUNTIME_WORKENV_ALIASES_LOADED || return 0

    alias we='shellc' \
        --desc "workenv shell for current/project dir" --tags "workenv,docker,shell"
    alias wev='nvimc' \
        --desc "workenv Neovim for current/project dir" --tags "workenv,docker,nvim,editor"
    alias wet='tmuxc' \
        --desc "workenv tmux for current/project dir" --tags "workenv,docker,tmux"
    alias westop='workenv-stop' \
        --desc "Stop workenv project container" --tags "workenv,docker,container"
    alias weclean='workenv-clean' \
        --desc "Clean stopped workenv containers/images" --tags "workenv,docker,cleanup"
}

runtime_plugin_workenv() {
    local _bin

    _bin=$(_runtime_workenv_bin_dir) || {
        ctx_set RUNTIME_WORKENV_AVAILABLE 0 plugin
        return 0
    }

    ctx_set RUNTIME_WORKENV_AVAILABLE 1 plugin
    ctx_set WORKENV_BIN "$_bin" plugin
    ctx_set WORKENV_HOME "${_bin%/bin}" plugin

    path_prepend "$_bin"

    runtime_workenv_aliases
}

hook_register setup runtime_plugin_workenv
