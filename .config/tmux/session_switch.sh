#!/bin/bash

SESSIONS=$(tmux list-sessions -F "#{session_name}")
SELECTED=$(echo "$SESSIONS" | fzf)

if [ -n "$SELECTED" ]; then
	tmux switch-client -t "$SELECTED"
fi
