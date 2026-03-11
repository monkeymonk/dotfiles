# eza — modern ls replacement.

runtime_plugin_eza() {
    require_cmd eza || return 0
    runtime_eza_aliases
}

runtime_eza_aliases() {
    guard_double_load RUNTIME_EZA_ALIASES_LOADED || return 0

    local _d="--icons --git --group-directories-first"

    # Basic listing
    alias ls="eza $_d"                          --desc "List files (eza)"              --tags "fs,ls,eza"
    alias l="eza $_d -1"                        --desc "List (one per line)"           --tags "fs,ls,eza"
    alias la="eza $_d -a"                       --desc "List all"                      --tags "fs,ls,eza"
    alias ll="eza $_d -l"                       --desc "List (long)"                   --tags "fs,ls,eza"
    alias lla="eza $_d -la"                     --desc "List all (long)"               --tags "fs,ls,eza"
    alias llg="eza $_d -la --git-ignore"        --desc "List all (git-aware)"          --tags "fs,ls,eza,git"

    # Sorted views
    alias lls="eza $_d -la --sort=size"         --desc "List all, sort by size"        --tags "fs,ls,eza,sort"
    alias llt="eza $_d -la --sort=modified"     --desc "List all, sort by time"        --tags "fs,ls,eza,sort"
    alias lln="eza $_d -la --sort=name"         --desc "List all, sort by name"        --tags "fs,ls,eza,sort"
    alias lle="eza $_d -la --sort=ext"          --desc "List all, sort by extension"   --tags "fs,ls,eza,sort"

    # Tree views
    alias lt="eza $_d --tree -L 2"              --desc "Tree (2 levels)"               --tags "fs,ls,eza,tree"
    alias lt3="eza $_d --tree -L 3"             --desc "Tree (3 levels)"               --tags "fs,ls,eza,tree"
    alias lta="eza $_d --tree -L 2 -a"          --desc "Tree all (2 levels)"           --tags "fs,ls,eza,tree"
    alias ltl="eza $_d -l --tree -L 2"          --desc "Tree (long, 2 levels)"         --tags "fs,ls,eza,tree"

    # Filtered views
    alias ld="eza $_d -lD"                      --desc "List directories only"         --tags "fs,ls,eza,dir"
    alias lf="eza $_d -lf"                      --desc "List files only"               --tags "fs,ls,eza,file"
}

hook_register setup runtime_plugin_eza
