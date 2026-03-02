# eza — modern ls replacement.

runtime_plugin_eza() {
    require_cmd eza || return 0
    runtime_eza_aliases
}

runtime_eza_aliases() {
    [ "${RUNTIME_EZA_ALIASES_LOADED-}" = "1" ] && return 0
    RUNTIME_EZA_ALIASES_LOADED=1

    local _defaults="--icons --git --group-directories-first"

    runtime_alias ls   "eza $_defaults"            --desc "List files (eza)"      --tags "fs,ls,eza"
    runtime_alias l    "eza $_defaults -l"         --desc "List (long)"           --tags "fs,ls,eza"
    runtime_alias la   "eza $_defaults -la"        --desc "List all (long)"       --tags "fs,ls,eza"
    runtime_alias ll   "eza $_defaults -l"         --desc "List (long)"           --tags "fs,ls,eza"
    runtime_alias lla  "eza $_defaults -la"        --desc "List all (long)"       --tags "fs,ls,eza"
    runtime_alias lt   "eza $_defaults --tree"     --desc "Tree view"             --tags "fs,ls,eza,tree"
    runtime_alias llt  "eza $_defaults -l --tree"  --desc "Tree view (long)"      --tags "fs,ls,eza,tree"
}

hook_register setup runtime_plugin_eza
