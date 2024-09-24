#!/bin/bash

# Get the current tmux session name
CURRENT_SESSION=$(tmux display-message -p '#S')

# Prompt for a filename (or use the session name by default)
FILENAME=$(echo "$CURRENT_SESSION" | fzf --print-query --header="Enter filename (default: $CURRENT_SESSION)" --expect=enter)

# Check the exit status of fzf
if [ $? -ne 0 ]; then
	# If fzf was canceled (e.g., via ESC), exit the script
	exit 0
fi

# Use the current session name if no filename is provided
if [ -z "$FILENAME" ]; then
	FILENAME=$CURRENT_SESSION
fi

# Save the session using tmuxp
tmuxp freeze -y --force "$FILENAME"
