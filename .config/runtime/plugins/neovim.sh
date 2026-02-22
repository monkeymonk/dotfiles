# Neovim integration.

runtime_plugin_neovim() {
	has_cmd nvim || return 0

	if [ -z "${EDITOR-}" ]; then
		export EDITOR="nvim"
	fi
	if [ -z "${VISUAL-}" ]; then
		export VISUAL="nvim"
	fi
	if [ -z "${MANPAGER-}" ]; then
		export MANPAGER="nvim +Man!"
	fi

	if command -v alx >/dev/null 2>&1 && command -v runtime_neovim_aliases >/dev/null 2>&1; then
		runtime_neovim_aliases
	fi
}

runtime_neovim_aliases() {
	[ "${RUNTIME_NEOVIM_ALIASES_LOADED-}" = "1" ] && return 0
	RUNTIME_NEOVIM_ALIASES_LOADED=1
	command -v alx >/dev/null 2>&1 || return 1
	alx add v "nvim" --desc "Neovim editor" --tags "nvim,editor"
	alx add vim "nvim" --desc "Neovim editor" --tags "nvim,editor"
	alx add vl "nvim +'lua require(\"persistence\").load()'" --desc "Neovim last session" --tags "nvim,editor,session"
}

runtime_hook_register post_config runtime_plugin_neovim
