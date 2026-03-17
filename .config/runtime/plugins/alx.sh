# alx integration — drop-in alias replacement.
#
# When alx is available, overrides the `alias` builtin so that every
# alias definition (from any plugin, config, or rc file) is captured
# in the alx registry while still creating the real shell alias.
#
# Accepts optional --desc and --tags flags (stripped before builtin alias):
#   alias gs='git status' --desc "Git status" --tags "git,status"
#
# Plain `alias` (no args) and `alias -p` work unchanged.
#
# Performance: metadata is buffered in memory and flushed to alx in a
# single background process at the interactive phase — no per-alias forks.

runtime_plugin_alx() {
    if [ -d "$HOME/.local/share/alx/bin" ]; then
        path_prepend "$HOME/.local/share/alx/bin"
    fi

    # Global so the alias() shim can see it after this function returns.
    _RUNTIME_HAS_ALX=0
    command -v alx >/dev/null 2>&1 && _RUNTIME_HAS_ALX=1

    # Buffer for deferred alx registration (tab-separated: name\tcmd\tdesc\ttags).
    _ALX_DEFERRED=""

    # Override alias builtin to accept --desc/--tags metadata.
    # When alx is available, buffers metadata for batch registration.
    # When alx is absent, strips metadata and falls through to builtin alias.
    # Passes flags (-p, -g, etc.) and bare lookups straight to builtin.
    alias() {
        if [ $# -eq 0 ]; then
            builtin alias
            return
        fi
        if [ "${1#-}" != "$1" ]; then
            builtin alias "$@"
            return
        fi

        # First pass: extract metadata, collect assignment args.
        local _alx_desc="" _alx_tags="" _name="" _cmd=""
        while [ $# -gt 0 ]; do
            case "$1" in
                --desc) _alx_desc="$2"; shift 2 ;;
                --tags) _alx_tags="$2"; shift 2 ;;
                *)
                    if [ "${1#*=}" != "$1" ]; then
                        _name="${1%%=*}" _cmd="${1#*=}"
                    fi
                    builtin alias "$1"
                    shift
                    ;;
            esac
        done

        # Buffer metadata for batch flush (only when we have desc/tags to register).
        if [ -n "$_name" ] && [ "${_RUNTIME_HAS_ALX:-0}" -eq 1 ] && \
           { [ -n "$_alx_desc" ] || [ -n "$_alx_tags" ]; }; then
            _ALX_DEFERRED="${_ALX_DEFERRED}${_name}	${_cmd}	${_alx_desc}	${_alx_tags}
"
        fi
    }

    if [ "$_RUNTIME_HAS_ALX" -eq 1 ]; then
        alias falx='eval "$(alx list | fzf --delimiter=$'\''\t'\'' --with-nth=1,2,3 | cut -f1)"' \
            --desc "Fuzzy search aliases" --tags "alias,fzf"
    fi
}

# Flush buffered metadata + import bare aliases in one background process.
_alx_flush_and_import() {
    command -v alx >/dev/null 2>&1 || return 0
    local _buf="$_ALX_DEFERRED"
    _ALX_DEFERRED=""
    (
        # First: import all current shell aliases (captures bare ones without metadata).
        builtin alias | alx import - --force 2>/dev/null
        # Then: overlay buffered entries that have desc/tags metadata.
        if [ -n "$_buf" ]; then
            printf '%s' "$_buf" | while IFS='	' read -r _n _c _d _t; do
                [ -n "$_n" ] || continue
                alx add "$_n" "$_c" --force \
                    ${_d:+--desc "$_d"} \
                    ${_t:+--tags "$_t"} 2>/dev/null
            done
        fi
    ) &!
}

hook_register bootstrap runtime_plugin_alx
hook_register interactive _alx_flush_and_import
