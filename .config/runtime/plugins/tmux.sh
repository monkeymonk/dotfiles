# Tmux integration.

runtime_plugin_tmux() {
	require_cmd tmux || return 0

	if [ -n "${TMUX_AUTO_ATTACH-}" ] && [ -z "${TMUX-}" ]; then
		tmux new-session -A -s Default -c ~
	fi

	if command -v alx >/dev/null 2>&1 && command -v runtime_tmux_aliases >/dev/null 2>&1; then
		runtime_tmux_aliases
	fi
}

runtime_tmux_aliases() {
	[ "${RUNTIME_TMUX_ALIASES_LOADED-}" = "1" ] && return 0
	RUNTIME_TMUX_ALIASES_LOADED=1
	command -v alx >/dev/null 2>&1 || return 1
	if [ -d "$HOME/.tmuxp" ] || has_cmd tmuxp; then
		alx add fux 'tmuxp load $(tmuxp ls | fzf --layout=reverse --info=inline --height=40%)' --desc "Tmuxp fuzzy search" --tags "tmux,session,search"
	fi
}

runtime_hook_register late runtime_plugin_tmux
