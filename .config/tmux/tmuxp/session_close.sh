#!/bin/bash

# List all active tmux sessions
SESSIONS=$(tmux list-sessions -F "#{session_name}")

# Use fzf to select a session
SELECTED=$(echo "$SESSIONS" | fzf --color=dark --info=hidden)

# If a session was selected, proceed to close it
if [ -n "$SELECTED" ]; then
  # Get the current tmux session name
  CURRENT_SESSION=$(tmux display-message -p '#S')

  # Check if the selected session is the current tmux session
  if [ "$CURRENT_SESSION" = "$SELECTED" ]; then
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

  # Kill the selected session in tmux, but keep the tmuxp config file
  tmux kill-session -t "$SELECTED"
fi
