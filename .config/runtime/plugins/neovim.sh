# Neovim integration.

runtime_plugin_neovim() {
	require_cmd nvim || return 0

	if [ -z "${EDITOR-}" ]; then
		export EDITOR="nvim"
	fi
	if [ -z "${VISUAL-}" ]; then
		export VISUAL="nvim"
	fi
	if [ -z "${MANPAGER-}" ]; then
		export MANPAGER="nvim +Man!"
	fi

	runtime_neovim_aliases
}

runtime_neovim_aliases() {
	[ "${RUNTIME_NEOVIM_ALIASES_LOADED-}" = "1" ] && return 0
	RUNTIME_NEOVIM_ALIASES_LOADED=1
	runtime_alias v "nvim" --desc "Neovim editor" --tags "nvim,editor"
	runtime_alias vim "nvim" --desc "Neovim editor" --tags "nvim,editor"
	runtime_alias vl "nvim +'lua require(\"persistence\").load()'" --desc "Neovim last session" --tags "nvim,editor,session"
}

runtime_hook_register setup runtime_plugin_neovim
