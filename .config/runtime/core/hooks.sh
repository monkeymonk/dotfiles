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

}

runtime_hook_run() {
    _phase=$1
    [ -n "$_phase" ] || return 1

    _var="RUNTIME_HOOKS_${_phase}"
    eval "_hooks=\${$_var-}"
    if [ -n "${ZSH_VERSION-}" ]; then
        setopt LOCAL_OPTIONS SH_WORD_SPLIT
    fi
    _old_ifs=$IFS
    IFS=' '
    for _fn in $_hooks; do
        if command -v "$_fn" >/dev/null 2>&1; then
            "$_fn"
        else
            warn "missing hook: $_fn (phase: $_phase)"
        fi
    done
    IFS=$_old_ifs
}
