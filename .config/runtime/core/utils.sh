# General helpers.

die() {
    printf '%s\n' "runtime: $*" >&2
    return 1
}

try_or_warn() {
    "$@" || warn "command failed: $*"
}

safe_source() {
    _file=$1
    [ -f "$_file" ] || return 1
    if . "$_file"; then
        return 0
    fi
    warn "failed to source $_file"
    return 1
}

guard_double_load() {
    _var=$1
    [ -n "$_var" ] || return 1
    eval "_val=\${${_var}-}"
    if [ -n "$_val" ]; then
        return 1
    fi
    eval "${_var}=1"
    return 0
}

require_cmd() {
    if ! has_cmd "$1"; then
        warn "missing command: $1"
        return 1
    fi
    return 0
}
