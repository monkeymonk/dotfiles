# FZF configuration.

runtime_plugin_fzf() {
	case ${-:-} in
	*i*) ;;
	*) return 0 ;;
	esac

	# Ensure default install location is on PATH.
	if [ -x "$HOME/.fzf/bin/fzf" ]; then
		path_prepend "$HOME/.fzf/bin"
	fi

	# Ensure the fzf binary exists before doing anything
	require_cmd fzf || return 0

	# Zsh-specific wrapper (only if not already defined as a function)
	if [ -n "${ZSH_VERSION-}" ] && [ -n "${ZSH-}" ]; then
		if ! type fzf 2>/dev/null | grep -q 'function'; then
			fzf() {
				if [ "$1" = "--zsh" ] && [ -d "$HOME/.fzf/shell" ]; then
					[ -f "$HOME/.fzf/shell/key-bindings.zsh" ] && cat "$HOME/.fzf/shell/key-bindings.zsh"
					[ -f "$HOME/.fzf/shell/completion.zsh" ] && cat "$HOME/.fzf/shell/completion.zsh"
					return 0
				fi
				command fzf "$@"
			}
		fi
	fi

	# Improve default search behavior if fd exists
	if require_cmd fd; then
		export FZF_DEFAULT_COMMAND="${FZF_DEFAULT_COMMAND:-fd --type f}"
	fi

	# Source shell integration files if available
	if [ -n "${SHELL_FAMILY-}" ]; then
		_runtime_fzf_sourced=0

		if [ -f "$HOME/.fzf/shell/key-bindings.${SHELL_FAMILY}" ]; then
			. "$HOME/.fzf/shell/key-bindings.${SHELL_FAMILY}"
			_runtime_fzf_sourced=1
		fi

		if [ -f "$HOME/.fzf/shell/completion.${SHELL_FAMILY}" ]; then
			. "$HOME/.fzf/shell/completion.${SHELL_FAMILY}"
			_runtime_fzf_sourced=1
		fi

		if [ "$_runtime_fzf_sourced" -eq 0 ] && [ -f "$HOME/.fzf.${SHELL_FAMILY}" ]; then
			. "$HOME/.fzf.${SHELL_FAMILY}"
		fi

		unset _runtime_fzf_sourced
	fi
}

hook_register setup runtime_plugin_fzf
