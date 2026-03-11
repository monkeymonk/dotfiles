# cdx integration.

runtime_plugin_cdx() {
    local HAS_CDX
    HAS_CDX=0
    if [ -f "$HOME/.local/bin/cdx.sh" ]; then
        safe_source "$HOME/.local/bin/cdx.sh" || true
    fi
    if [ -d "$HOME/.local/bin/completions" ] && [ "$SHELL_FAMILY" = "zsh" ]; then
        fpath=("$HOME/.local/bin/completions" $fpath)
    elif [ -f "$HOME/.local/bin/completions/cdx.${SHELL_FAMILY}" ]; then
        safe_source "$HOME/.local/bin/completions/cdx.${SHELL_FAMILY}" || true
    fi
    if command -v cdx >/dev/null 2>&1; then
        HAS_CDX=1
    fi

    runtime_cdx_aliases() {
        guard_double_load RUNTIME_CDX_ALIASES_LOADED || return 0
        [ "$HAS_CDX" -eq 1 ] || return 0

        alias cd='cdx' --desc "cd via cdx" --tags "cdx,nav,cd"
        alias up='cdx --up' --desc "up via cdx" --tags "cdx,nav,up"
    }

    runtime_cdx_aliases
}

hook_register interactive runtime_plugin_cdx
