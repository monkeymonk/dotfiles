# Hook registry for bootstrap phases.

_runtime_hook_var() {
    printf '%s\n' "RUNTIME_HOOKS_${1}"
}

_runtime_hook_init_array() {
    _var=$1
    if [ -n "${ZSH_VERSION-}" ]; then
        eval "typeset -ga ${_var} >/dev/null 2>&1 || true"
    else
        eval "declare -g -a ${_var} >/dev/null 2>&1 || true"
    fi
}

runtime_hook_register() {
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
    _phase=$1
    [ -n "$_phase" ] || return 1

    _var=$(_runtime_hook_var "$_phase")
    eval "_len=\${#${_var}[@]-0}"
    if [ "${_len}" -eq 0 ]; then
        return 0
    fi
    eval "_hooks=(\"\${${_var}[@]}\")"

    for _fn in "${_hooks[@]}"; do
        [ -n "$_fn" ] || continue
        if command -v "$_fn" >/dev/null 2>&1; then
            "$_fn"
        else
            warn "missing hook: $_fn (phase: $_phase)"
        fi
    done
}
