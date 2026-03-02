# Generic tagged key-value registry with lazy evaluation.

registry_init() {
    eval "_REGISTRY_$1=''"
}

registry_add() {
    local _ns="$1" _key="$2" _tag="${3:-_}"
    eval "_REGISTRY_${_ns}=\"\${_REGISTRY_${_ns}:+\${_REGISTRY_${_ns}} }${_key}:${_tag}:eager\""
}

registry_add_lazy() {
    local _ns="$1" _key="$2" _fn="$3" _tag="${4:-_}"
    eval "_REGISTRY_${_ns}=\"\${_REGISTRY_${_ns}:+\${_REGISTRY_${_ns}} }${_key}:${_tag}:lazy\""
    eval "_REGISTRY_${_ns}_LAZY_${_key}=${_fn}"
}

registry_resolve() {
    local _ns="$1" _key="$2" _fn_var _fn
    _fn_var="_REGISTRY_${_ns}_LAZY_${_key}"
    eval "_fn=\${${_fn_var}:-}"
    [ -n "$_fn" ] || return 0
    "$_fn"
    unset "$_fn_var"
    # Flip mode from lazy to eager
    eval "_REGISTRY_${_ns}=\"\$(printf '%s' \"\${_REGISTRY_${_ns}}\" | sed \"s/${_key}:\\([^:]*\\):lazy/${_key}:\\1:eager/\")\""
}

registry_get() {
    local _ns="$1" _key="$2"
    registry_resolve "$_ns" "$_key"
    eval "printf '%s\n' \"\${${_key}:-}\""
}

registry_dump() {
    [ -n "${ZSH_VERSION-}" ] && setopt LOCAL_OPTIONS SH_WORD_SPLIT
    local _ns="$1" _tag_filter="" _do_resolve=0 _entries _entry _key _tag _mode
    shift
    while [ $# -gt 0 ]; do
        case "$1" in
            --tag) _tag_filter="$2"; shift 2 ;;
            --resolve) _do_resolve=1; shift ;;
            *) shift ;;
        esac
    done

    eval "_entries=\${_REGISTRY_${_ns}:-}"
    for _entry in $_entries; do
        _key="${_entry%%:*}"
        _tag="${_entry#*:}"; _tag="${_tag%%:*}"
        _mode="${_entry##*:}"

        [ -n "$_key" ] || continue
        [ -z "$_tag_filter" ] || [ "$_tag" = "$_tag_filter" ] || continue

        if [ "$_mode" = "lazy" ] && [ "$_do_resolve" = "1" ]; then
            registry_resolve "$_ns" "$_key"
        fi
        eval "printf '%s=%s\n' '$_key' \"\${${_key}:-}\""
    done
}
