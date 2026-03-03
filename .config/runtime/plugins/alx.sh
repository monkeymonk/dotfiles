# alx integration — drop-in alias replacement.
#
# When alx is available, overrides the `alias` builtin so that every
# alias definition (from any plugin, config, or rc file) is captured
# in the alx registry while still creating the real shell alias.
#
# Plain `alias` (no args) and `alias -p` work unchanged.

runtime_plugin_alx() {
    if [ -d "$HOME/.local/share/alx/bin" ]; then
        path_prepend "$HOME/.local/share/alx/bin"
    fi

    command -v alx >/dev/null 2>&1 || return 0

    # Shim: intercept alias definitions, persist in alx, define real alias.
    # Handles multiple definitions: alias a='foo' b='bar'
    # Passes flags (-p, -g, etc.) and lookups straight to builtin.
    _alx_shim_alias() {
        if [ $# -eq 0 ]; then
            builtin alias
            return
        fi
        # Flags go straight through
        if [ "${1#-}" != "$1" ]; then
            builtin alias "$@"
            return
        fi
        local arg name cmd
        for arg in "$@"; do
            if [ "${arg#*=}" != "$arg" ]; then
                name="${arg%%=*}" cmd="${arg#*=}"
                alx add "$name" "$cmd" --force 2>/dev/null
            fi
        done
        builtin alias "$@"
    }

    alias() { _alx_shim_alias "$@"; }

    runtime_alias falx 'eval "$(alx list | fzf --delimiter=$'\''\t'\'' --with-nth=1,2,3 | cut -f1)"' \
        --desc "Fuzzy search aliases" --tags "alias,fzf"
}

# Sweep: import any aliases defined before the shim was active
# (oh-my-zsh, other rc files, external tools, etc.)
_alx_import_existing() {
    command -v alx >/dev/null 2>&1 || return 0
    builtin alias | alx import - 2>/dev/null
}

hook_register bootstrap runtime_plugin_alx
hook_register interactive _alx_import_existing
