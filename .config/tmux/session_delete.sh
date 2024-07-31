#!/bin/bash

# List all tmux sessions
SESSIONS=$(tmux list-sessions -F "#{session_name}")

# Use fzf to select a session
SELECTED=$(echo "$SESSIONS" | fzf)

# If a session was selected, proceed to delete it
if [ -n "$SELECTED" ]; then
	# Get the current session name
	CURRENT_SESSION=$(tmux display-message -p '#S')

	# Check if the selected session is the current session
	if [ "$CURRENT_SESSION" = "$SELECTED" ]; then
		# Get the remaining sessions
		REMAINING_SESSIONS=$(tmux list-sessions -F "#{session_name}" | grep -v "^$SELECTED$")

		if [ -n "$REMAINING_SESSIONS" ]; then
			# Switch to the first remaining session
			FIRST_SESSION=$(echo "$REMAINING_SESSIONS" | head -n 1)
			tmux switch-client -t "$FIRST_SESSION"
		else
			# Create and switch to a new session if no other sessions are left
			tmux new-session -d -s "default" && tmux switch-client -t "default"
		fi
	fi

	# Finally, kill the selected session
	tmux kill-session -t "$SELECTED"
fi
