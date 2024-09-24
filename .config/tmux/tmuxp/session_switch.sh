#!/bin/bash

SESSIONS=$(tmuxp ls)
SELECTED=$(echo "$SESSIONS" | fzf)

if [ -n "$SELECTED" ]; then
	# Check if the selected session is already loaded
	if tmux has-session -t "$SELECTED" 2>/dev/null; then
		# Switch to the selected session
		tmux switch-client -t "$SELECTED"
	else
		# Load the session with tmuxp and switch to it
		tmuxp load -y "$SELECTED"
		tmux switch-client -t "$SELECTED"
	fi
fi
