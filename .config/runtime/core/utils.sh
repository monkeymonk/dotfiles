# General helpers.

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

has_file() {
    [ -f "$1" ]
}

has_dir() {
    [ -d "$1" ]
}

die() {
    printf '%s\n' "runtime: $*" >&2
    return 1
}

try_or_warn() {
    "$@" || warn "command failed: $*"
}

safe_source() {
    local _file
    _file=$1
    [ -f "$_file" ] || return 1
    if . "$_file"; then
        return 0
    fi
    warn "failed to source $_file"
    return 1
}

guard_double_load() {
    local _var _val
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
