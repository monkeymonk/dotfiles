#!/bin/bash

if [ -z "$1" ]; then
	echo "Session name is required."
	exit 1
fi

NEW_SESSION_NAME="$1"

# Create a new session and switch to it
tmux new-session -d -s "$NEW_SESSION_NAME" && tmux switch-client -t "$NEW_SESSION_NAME"
