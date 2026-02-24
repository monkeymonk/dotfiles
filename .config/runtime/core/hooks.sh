# Hook registry for bootstrap phases.

_runtime_hook_var() {
    printf '%s\n' "RUNTIME_HOOKS_${1}"
}

_runtime_hook_init_array() {
    local _var
    _var=$1
    if [ -n "${ZSH_VERSION-}" ]; then
        eval "typeset -ga ${_var} >/dev/null 2>&1 || true"
    else
        eval "declare -g -a ${_var} >/dev/null 2>&1 || true"
    fi
}

runtime_hook_register() {
    local _phase _fn _var
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

    _var=$(_runtime_hook_var "$_phase")
    _runtime_hook_init_array "$_var"
    eval "${_var}+=(\"$_fn\")"
}

runtime_hook_run() {
    local _phase _var _len _fn _t0 _t1
    _phase=$1
    [ -n "$_phase" ] || return 1

    _var=$(_runtime_hook_var "$_phase")
    eval "_len=\${#${_var}[@]-0}"
    if [ "${_len}" -eq 0 ]; then
        return 0
    fi

    # Copy hooks into a local array to handle zsh 1-based indexing.
    local _hooks
    eval "_hooks=(\"\${${_var}[@]}\")"
    for _fn in "${_hooks[@]}"; do
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

# Print registered hooks and RUNTIME_* vars for debugging.
runtime_status() {
    local _phase _var _len _fn _hooks
    printf 'RUNTIME_ROOT:    %s\n' "${RUNTIME_ROOT:-unset}"
    printf 'RUNTIME_OS:      %s\n' "${RUNTIME_OS:-unset}"
    printf 'RUNTIME_DISTRO:  %s\n' "${RUNTIME_DISTRO:-unset}"
    printf 'RUNTIME_HOST:    %s\n' "${RUNTIME_HOST:-unset}"
    printf 'RUNTIME_IS_WORK: %s\n' "${RUNTIME_IS_WORK:-0}"
    printf 'RUNTIME_IS_HOME: %s\n' "${RUNTIME_IS_HOME:-0}"
    printf 'SHELL_FAMILY:    %s\n' "${SHELL_FAMILY:-unset}"
    printf '\nHooks:\n'
    for _phase in bootstrap setup post_secrets interactive; do
        _var=$(_runtime_hook_var "$_phase")
        eval "_len=\${#${_var}[@]-0}"
        if [ "${_len:-0}" -eq 0 ]; then
            printf '  %-16s (none)\n' "$_phase"
            continue
        fi
        printf '  %s:\n' "$_phase"
        eval "_hooks=(\"\${${_var}[@]}\")"
        for _fn in "${_hooks[@]}"; do
            printf '    - %s\n' "$_fn"
        done
    done
}
