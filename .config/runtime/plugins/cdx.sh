# cdx integration.

runtime_plugin_cdx() {
    HAS_CDX=0
    if [ -f "$HOME/.local/share/cdx/cdx.sh" ]; then
        HAS_CDX=1
    elif command -v cdx >/dev/null 2>&1; then
        HAS_CDX=1
    fi

    runtime_cdx_aliases() {
        [ "$HAS_CDX" -eq 1 ] || return 0
        command -v alx >/dev/null 2>&1 || return 1

        alx add cd 'cdx' --desc "cd via cdx" --tags "cdx,nav"
        alx add up 'cdx_up' --desc "up via cdx" --tags "cdx,nav"
    }
}

runtime_hook_register post_scripts runtime_plugin_cdx
