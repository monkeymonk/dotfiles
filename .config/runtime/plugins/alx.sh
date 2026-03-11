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

runtime_plugin_alx() {
    if [ -d "$HOME/.local/share/alx/bin" ]; then
        path_prepend "$HOME/.local/share/alx/bin"
    fi

    # Global so the alias() shim can see it after this function returns.
    _RUNTIME_HAS_ALX=0
    command -v alx >/dev/null 2>&1 && _RUNTIME_HAS_ALX=1

    # Override alias builtin to accept --desc/--tags metadata.
    # When alx is available, registers in alx registry.
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

        # Register in alx after metadata is fully parsed.
        if [ -n "$_name" ] && [ "${_RUNTIME_HAS_ALX:-0}" -eq 1 ]; then
            alx add "$_name" "$_cmd" --force \
                ${_alx_desc:+--desc "$_alx_desc"} \
                ${_alx_tags:+--tags "$_alx_tags"} 2>/dev/null
        fi
    }

    if [ "$_RUNTIME_HAS_ALX" -eq 1 ]; then
        alias falx='eval "$(alx list | fzf --delimiter=$'\''\t'\'' --with-nth=1,2,3 | cut -f1)"' \
            --desc "Fuzzy search aliases" --tags "alias,fzf"
    fi
}

# Sweep: import any aliases defined before the shim was active
# (oh-my-zsh, other rc files, external tools, etc.)
_alx_import_existing() {
    command -v alx >/dev/null 2>&1 || return 0
    builtin alias | alx import - 2>/dev/null
}

hook_register bootstrap runtime_plugin_alx
hook_register interactive _alx_import_existing
