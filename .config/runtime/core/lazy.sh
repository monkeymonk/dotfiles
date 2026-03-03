# lazy.sh — lazy_load utility
# Usage: lazy_load <loader_fn> <cmd1> [cmd2 ...]
#
# Creates a stub for each cmd. On first call of any stub:
#   1. Unsets ALL stubs registered in this batch
#   2. Runs loader_fn
#   3. Re-executes the original command with original args

lazy_load() {
    local _loader_fn="$1"; shift
    local _unset_cmd _cmd
    if [ -n "${ZSH_VERSION-}" ]; then
        _unset_cmd="unfunction"
    else
        _unset_cmd="unset -f"
    fi
    for _cmd in "$@"; do
        _unset_cmd="$_unset_cmd $_cmd"
    done
    for _cmd in "$@"; do
        eval "${_cmd}() { ${_unset_cmd}; ${_loader_fn}; ${_cmd} \"\$@\"; }"
    done
}
