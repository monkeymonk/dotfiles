#!/bin/bash

# List all tmuxp sessions (yaml files in ~/.tmuxp)
SESSIONS=$(tmuxp ls)

# Use fzf to select a session
SELECTED=$(echo "$SESSIONS" | fzf)

# If a session was selected, proceed to edit it
if [ -n "$SELECTED" ]; then
	# Open the selected session file in the editor (replace with your preferred editor)
	nvim ~/.tmuxp/"$SELECTED".yaml
fi
