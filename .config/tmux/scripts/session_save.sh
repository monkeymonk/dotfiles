#!/usr/bin/env bash
# Save current tmux session to tmuxp YAML config (interactive)
SESSION=$(tmux display-message -p '#S')
DEST="$HOME/.tmuxp"

mkdir -p "$DEST"

echo "Saving session: $SESSION"
echo "Output: ${DEST}/${SESSION}.yaml"
echo ""

tmuxp freeze -f yaml -o "${DEST}/${SESSION}.yaml" "$SESSION"

echo ""
echo "Done. Press any key to close."
read -rsn1
