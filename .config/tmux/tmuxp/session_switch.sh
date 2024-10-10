#!/bin/bash

CURRENT_SESSION=$(tmux display-message -p '#S')
SESSIONS=$(tmuxp ls)
SELECTED=$(echo "$SESSIONS" | awk -v cur="$CURRENT_SESSION" '{print $1}' | while read -r session; do
	if [ "$session" == "$cur" ] || tmux has-session -t "$session" 2>/dev/null; then
		echo "$session*"
	else
		echo "$session"
	fi
done | fzf | awk -F'*' '{print $1}')

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
