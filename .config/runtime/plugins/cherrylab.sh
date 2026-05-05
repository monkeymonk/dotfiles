# cherrylab — thin shell wrapper for the `cherrylab` CLI (scripts/cherrylab).
#
# All command logic lives in the binary. This plugin only adds:
#   - $CHERRYLAB_DIR default
#   - `cherrylab cd` (must run in the parent shell to change CWD)
#   - tab completion (zsh + bash)

runtime_plugin_cherrylab() {
    has_cmd docker || return 0
    has_cmd cherrylab || return 0

    export CHERRYLAB_DIR="${CHERRYLAB_DIR:-$HOME/Works/cbtw/tools/cherrylab}"

    cherrylab() {
        if [ "${1:-}" = "cd" ]; then
            cd "$CHERRYLAB_DIR"
            return
        fi
        command cherrylab "$@"
    }

    _cherrylab_register_completion
}

_cherrylab_register_completion() {
    if [ -n "${ZSH_VERSION-}" ]; then
        # Defined via eval — body uses zsh-only syntax that bash would fail to parse.
        eval '
        _cherrylab_zsh_completion() {
            local -a subcmds proj_svcs lab_svcs targets
            subcmds=(
                "up:Start CherryLab stack"
                "down:Stop CherryLab stack"
                "restart:Restart lab|project|all|<svc>"
                "pull:Pull latest images"
                "update:git pull + pull + up"
                "start:Start CherryLab + project (CWD)"
                "stop:Stop project (CWD) + CherryLab"
                "status:Show services"
                "ps:Show services"
                "logs:Tail logs"
                "open:Open URL in browser"
                "url:Print URL"
                "shell:Exec into service"
                "exec:Exec into service"
                "services:List service names"
                "cd:cd into CHERRYLAB_DIR"
                "help:Show help"
            )
            if (( CURRENT == 2 )); then
                _describe -t commands "cherrylab command" subcmds
                return
            fi
            case "${words[2]}" in
                logs|open|url|shell|exec)
                    proj_svcs=(${(f)"$(command cherrylab services project 2>/dev/null)"})
                    lab_svcs=(${(f)"$(command cherrylab services lab 2>/dev/null)"})
                    (( ${#proj_svcs} )) && _describe -t project "project" proj_svcs
                    (( ${#lab_svcs} )) && _describe -t cherrylab "cherrylab" lab_svcs
                    ;;
                restart)
                    targets=(
                        "lab:Restart CherryLab stack"
                        "project:Restart CWD project"
                        "all:Restart both"
                    )
                    _describe -t targets "target" targets
                    proj_svcs=(${(f)"$(command cherrylab services project 2>/dev/null)"})
                    lab_svcs=(${(f)"$(command cherrylab services lab 2>/dev/null)"})
                    (( ${#proj_svcs} )) && _describe -t project "project" proj_svcs
                    (( ${#lab_svcs} )) && _describe -t cherrylab "cherrylab" lab_svcs
                    ;;
                services)
                    targets=("lab" "project" "all" "current")
                    _describe -t targets "target" targets
                    ;;
            esac
        }
        '
        compdef _cherrylab_zsh_completion cherrylab 2>/dev/null
    elif [ -n "${BASH_VERSION-}" ]; then
        _cherrylab_bash_completion() {
            local cur cmd cmds proj_svcs lab_svcs all svc
            COMPREPLY=()
            cur="${COMP_WORDS[COMP_CWORD]}"
            cmd="${COMP_WORDS[1]}"
            cmds="up down restart pull update start stop status ps logs open url shell exec services cd help"
            if [ "$COMP_CWORD" -eq 1 ]; then
                COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
                return
            fi
            case "$cmd" in
                logs|open|url|shell|exec|restart)
                    proj_svcs="$(command cherrylab services project 2>/dev/null)"
                    lab_svcs="$(command cherrylab services lab 2>/dev/null)"
                    all="$proj_svcs"
                    for svc in $lab_svcs; do
                        case " $proj_svcs " in
                            *" $svc "*) ;;
                            *) all="$all $svc" ;;
                        esac
                    done
                    [ "$cmd" = "restart" ] && all="lab project all $all"
                    COMPREPLY=( $(compgen -W "$all" -- "$cur") )
                    ;;
                services)
                    COMPREPLY=( $(compgen -W "lab project all current" -- "$cur") )
                    ;;
            esac
        }
        complete -F _cherrylab_bash_completion cherrylab
    fi
}

hook_register interactive runtime_plugin_cherrylab
