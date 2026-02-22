# Hook registry for bootstrap phases.

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

    _var="RUNTIME_HOOKS_${_phase}"
    eval "_current=\${$_var-}"
    if [ -n "$_current" ]; then
        eval "$_var=\"$_current $_fn\""
    else
        eval "$_var=\"$_fn\""
    fi

    _runtime_hook_register_all "$_fn"
}

runtime_hook_run() {
    _phase=$1
    [ -n "$_phase" ] || return 1

    _var="RUNTIME_HOOKS_${_phase}"
    eval "_hooks=\${$_var-}"
    for _fn in $_hooks; do
        if command -v "$_fn" >/dev/null 2>&1; then
            "$_fn"
        else
            warn "missing hook: $_fn (phase: $_phase)"
        fi
    done
}

_runtime_hook_list_has() {
    _list=$1
    _item=$2
    case " $_list " in
        *" $_item "*) return 0 ;;
    esac
    return 1
}

_runtime_hook_register_all() {
    _fn=$1
    [ -n "$_fn" ] || return 1
    if _runtime_hook_list_has "${RUNTIME_HOOKS_ALL-}" "$_fn"; then
        return 0
    fi
    if [ -n "${RUNTIME_HOOKS_ALL-}" ]; then
        RUNTIME_HOOKS_ALL="$RUNTIME_HOOKS_ALL $_fn"
    else
        RUNTIME_HOOKS_ALL="$_fn"
    fi
}
