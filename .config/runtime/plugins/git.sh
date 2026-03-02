# Git integration.

runtime_plugin_git() {
    require_cmd git || return 0

    export GIT_PAGER="${GIT_PAGER:-less}"

    runtime_git_aliases() {
        runtime_alias gs 'git status' --desc "Git status" --tags "git,status"
        runtime_alias ga 'git add' --desc "Git add" --tags "git,add"
        runtime_alias gc 'git commit' --desc "Git commit" --tags "git,commit"
        runtime_alias gp 'git push' --desc "Git push" --tags "git,push"
        runtime_alias gl 'git log' --desc "Git log" --tags "git,log"
        runtime_alias gd 'git diff' --desc "Git diff" --tags "git,diff"
        runtime_alias gds 'git diff --staged' --desc "Git diff --staged" --tags "git,diff,staged"
        runtime_alias gf 'git fetch' --desc "Git fetch" --tags "git,fetch"
    }

    runtime_git_aliases
}

hook_register setup runtime_plugin_git
