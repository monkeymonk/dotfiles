#!/bin/bash

SESSION_DIR="$HOME/.tmuxp"
LAST_SESSIONS_FILE="$HOME/.tmuxp_last_sessions"

if [ -f "$LAST_SESSIONS_FILE" ]; then
	while IFS= read -r session_name; do
		# sometine session name is in lowercase while the file use capital letters
		session_config=$(find "$SESSION_DIR" -iname "$session_name.yaml" -print -quit)

		if [ -n "$session_config" ] && [ -f "$session_config" ]; then
			actual_session_name=$(basename "$session_config" .yaml)

			tmuxp load "$actual_session_name"
		fi
	done <"$LAST_SESSIONS_FILE"
fi
