# Git integration.

runtime_plugin_git() {
    require_cmd git || return 0

    export GIT_PAGER="${GIT_PAGER:-less}"

    runtime_git_aliases() {
        command -v alx >/dev/null 2>&1 || return 1

        alx add gs 'git status' --desc "Git status" --tags "git"
        alx add ga 'git add' --desc "Git add" --tags "git"
        alx add gc 'git commit' --desc "Git commit" --tags "git"
        alx add gp 'git push' --desc "Git push" --tags "git"
        alx add gl 'git log' --desc "Git log" --tags "git"
        alx add gd 'git diff' --desc "Git diff" --tags "git"
        alx add gds 'git diff --staged' --desc "Git diff --staged" --tags "git"
        alx add gf 'git fetch' --desc "Git fetch" --tags "git"
    }
}

runtime_hook_register post_config runtime_plugin_git
