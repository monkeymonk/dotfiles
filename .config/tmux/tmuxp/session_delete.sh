#!/bin/bash

# List all tmuxp sessions
SESSIONS=$(tmuxp ls)

# Use fzf to select a session
SELECTED=$(echo "$SESSIONS" | fzf)

# If a session was selected, proceed to delete it
if [ -n "$SELECTED" ]; then
	# Get the current tmux session name
	CURRENT_SESSION=$(tmux display-message -p '#S')

	# Check if the selected session is the current tmux session
	if tmux has-session -t "$SELECTED" 2>/dev/null && [ "$CURRENT_SESSION" = "$SELECTED" ]; then
		# Get the remaining active tmux sessions
		REMAINING_SESSIONS=$(tmux list-sessions -F "#{session_name}" | grep -v "^$SELECTED$")

		if [ -n "$REMAINING_SESSIONS" ]; then
			# Switch to the first remaining session
			FIRST_SESSION=$(echo "$REMAINING_SESSIONS" | head -n 1)
			tmux switch-client -t "$FIRST_SESSION"
		else
			# Create and switch to a new default session if no other sessions are left
			tmux new-session -d -s "default" && tmux switch-client -t "default"
		fi
	fi

	# Finally, kill the selected session in tmux
	if tmux has-session -t "$SELECTED" 2>/dev/null; then
		tmux kill-session -t "$SELECTED"
	fi

	# Remove the corresponding tmuxp yaml file
	if [ -f ~/.tmuxp/"$SELECTED".yaml ]; then
		rm ~/.tmuxp/"$SELECTED".yaml
	fi
fi
