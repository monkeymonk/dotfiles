#!/bin/bash

# List all active tmux sessions
SESSIONS=$(tmux list-sessions -F "#{session_name}")

# Use fzf to select a session
SELECTED=$(echo "$SESSIONS" | fzf)

# If a session was selected, proceed to rename it
if [ -n "$SELECTED" ]; then
	# Prompt for the new session name
	NEW_NAME=$(echo "" | fzf --print-query --header="Enter new session name" --expect=enter | sed -n '1p')

	if [ -n "$NEW_NAME" ]; then
		# Rename the session in tmux
		tmux rename-session -t "$SELECTED" "$NEW_NAME"

		# Rename the corresponding tmuxp yaml file, if it exists
		if [ -f ~/.tmuxp/"$SELECTED".yaml ]; then
			mv ~/.tmuxp/"$SELECTED".yaml ~/.tmuxp/"$NEW_NAME".yaml
		fi
	fi
fi
