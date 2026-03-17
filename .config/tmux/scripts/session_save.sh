#!/usr/bin/env bash
# Save current tmux session to tmuxp YAML config
# Usage: session_save.sh <save_name>
SESSION=$(tmux display-message -p '#S')
NAME="${1:-$SESSION}"
DEST="$HOME/.tmuxp/${NAME}.yaml"

if tmuxp freeze -f yaml -o "$DEST" "$SESSION" 2>/dev/null; then
  # Rename session if name differs
  [ "$NAME" != "$SESSION" ] && tmux rename-session "$NAME"
  tmux display-message "Session saved as '${NAME}' → ${DEST}"
else
  tmux display-message "Failed to save session '${SESSION}'"
fi
