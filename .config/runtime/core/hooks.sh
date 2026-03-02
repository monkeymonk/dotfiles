# Hook registry for bootstrap phases.
# Pure POSIX string-based storage — no arrays, no shell-specific branching.

_HOOKS_PHASES=""

_hook_var() {
    printf '_HOOKS_%s' "$1"
}

_hook_track_phase() {
    case " $_HOOKS_PHASES " in
        *" $1 "*) return 0 ;;
    esac
    _HOOKS_PHASES="${_HOOKS_PHASES:+$_HOOKS_PHASES }$1"
}

hook_register() {
    local _phase _fn _var _cur
    _phase=$1
    _fn=$2

    [ -n "$_phase" ] || return 1
    [ -n "$_fn" ] || return 1

    case "$_fn" in
        *[!a-zA-Z0-9_]*)
            warn "invalid hook function name: $_fn"
            return 1
            ;;
    esac

    _var=$(_hook_var "$_phase")
    eval "_cur=\${${_var}-}"
    case " $_cur " in
        *" $_fn "*) return 0 ;;
    esac
    eval "${_var}=\"\${${_var}:+\${${_var}} }${_fn}\""
    _hook_track_phase "$_phase"
}

hook_run() {
    local _phase _var _hooks _fn _t0 _t1
    _phase=$1
    [ -n "$_phase" ] || return 1

    _var=$(_hook_var "$_phase")
    eval "_hooks=\${${_var}-}"
    [ -n "$_hooks" ] || return 0

    # Ensure word splitting in zsh
    if [ -n "${ZSH_VERSION-}" ]; then
        setopt LOCAL_OPTIONS SH_WORD_SPLIT
    fi

    for _fn in $_hooks; do
        [ -n "$_fn" ] || continue
        if command -v "$_fn" >/dev/null 2>&1; then
            if [ "${RUNTIME_DEBUG:-0}" = "1" ]; then
                _t0=$(date +%s%N 2>/dev/null || date +%s)
                "$_fn"
                _t1=$(date +%s%N 2>/dev/null || date +%s)
                printf '[runtime:debug] %s %sms\n' "$_fn" "$(( (_t1 - _t0) / 1000000 ))" >&2
            else
                "$_fn"
            fi
        else
            warn "missing hook: $_fn (phase: $_phase)"
        fi
    done
}

hook_list() {
    local _filter _phase _var _hooks _fn
    _filter=${1-}

    if [ -n "${ZSH_VERSION-}" ]; then
        setopt LOCAL_OPTIONS SH_WORD_SPLIT
    fi

    for _phase in $_HOOKS_PHASES; do
        [ -z "$_filter" ] || [ "$_phase" = "$_filter" ] || continue
        _var=$(_hook_var "$_phase")
        eval "_hooks=\${${_var}-}"
        if [ -z "$_hooks" ]; then
            printf '  %-16s (none)\n' "$_phase"
            continue
        fi
        printf '  %s:\n' "$_phase"
        for _fn in $_hooks; do
            printf '    - %s\n' "$_fn"
        done
    done
}
