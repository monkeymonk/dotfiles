# cdx integration.

runtime_plugin_cdx() {
	local HAS_CDX
	HAS_CDX=0
	if [ -f "$HOME/.local/bin/cdx.sh" ]; then
		safe_source "$HOME/.local/bin/cdx.sh" || true
	fi
	if command -v cdx >/dev/null 2>&1; then
		HAS_CDX=1
	fi

	runtime_cdx_aliases() {
		[ "${RUNTIME_CDX_ALIASES_LOADED-}" = "1" ] && return 0
		RUNTIME_CDX_ALIASES_LOADED=1
		[ "$HAS_CDX" -eq 1 ] || return 0

		# runtime_alias cd 'cdx' --desc "cd via cdx" --tags "cdx,nav,cd"
		runtime_alias up 'cdx --up' --desc "up via cdx" --tags "cdx,nav,up"
	}

	runtime_cdx_aliases
}

runtime_hook_register interactive runtime_plugin_cdx
