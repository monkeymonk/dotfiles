# Git integration.

runtime_plugin_git() {
    require_cmd git || return 0

    export GIT_PAGER="${GIT_PAGER:-less}"

    runtime_git_aliases() {
        alias gs='git status' --desc "Git status" --tags "git,status"
        alias ga='git add' --desc "Git add" --tags "git,add"
        alias gc='git commit' --desc "Git commit" --tags "git,commit"
        alias gp='git push' --desc "Git push" --tags "git,push"
        alias gl='git log' --desc "Git log" --tags "git,log"
        alias gd='git diff' --desc "Git diff" --tags "git,diff"
        alias gds='git diff --staged' --desc "Git diff --staged" --tags "git,diff,staged"
        alias gf='git fetch' --desc "Git fetch" --tags "git,fetch"
    }

    runtime_git_aliases
}

hook_register setup runtime_plugin_git
