#!/bin/bash

CURRENT_SESSION=$(tmux display-message -p '#S')
SESSIONS=$(tmuxp ls)

# Create arrays for active and inactive sessions
ACTIVE_SESSIONS=()
INACTIVE_SESSIONS=()

# Populate the arrays based on session status
while read -r session; do
  if [ "$session" == "$CURRENT_SESSION" ] || tmux has-session -t "$session" 2>/dev/null; then
    ACTIVE_SESSIONS+=("$session *")
  else
    INACTIVE_SESSIONS+=("$session")
  fi
done <<<"$(echo "$SESSIONS" | awk '{print $1}')"

# Combine active and inactive sessions
COMBINED_SESSIONS=("${ACTIVE_SESSIONS[@]}" "${INACTIVE_SESSIONS[@]}")

# Use fzf to select from the combined list
SELECTED=$(printf "%s\n" "${COMBINED_SESSIONS[@]}" | fzf --color=dark --info=hidden | awk -F' *' '{print $1}')

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
