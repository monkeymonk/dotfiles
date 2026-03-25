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
        alias glogf='git log --color=always --pretty=format:"%C(yellow)%h%Creset|%C(cyan)%ad%Creset|%C(green)%<(18,trunc)%an%Creset|%s" --date=format:"%Y-%m-%d %H:%M:%S"'
        alias gfzl='glogf | fzf --ansi --delimiter="|" --with-nth=1,2,3,4 --preview '\''echo {1} | sed "s/\x1b\[[0-9;]*m//g" | xargs -I % git show --color=always --stat --patch %'\'' --preview-window=right:70%'
    }

    runtime_git_aliases
}

hook_register setup runtime_plugin_git
