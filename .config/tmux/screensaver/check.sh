#!/usr/bin/env bash
# Screensaver check — called by tmux status-right #()
# Runs once per status-interval, no loops, no daemons.

# Hardcoded to avoid 2x tmux show-option forks per status refresh.
# Change here if you update @screensaver_idle or @screensaver_window in tmux.conf.
LIMIT=300
WINDOW_NAME=matrix
STARTER="$HOME/.config/tmux/screensaver/start.sh"

# Compute idle from client_activity (epoch timestamp)
ACTIVITY=$(command tmux list-clients -F '#{client_activity}' 2>/dev/null | sort -rn | head -1)
[ -z "$ACTIVITY" ] && exit 0

NOW=$(printf '%(%s)T' -1 2>/dev/null || date +%s)
IDLE=$((NOW - ACTIVITY))

[ "$IDLE" -ge "$LIMIT" ] || exit 0

# Only check for existing window when idle threshold is reached
HAS_WINDOW=$(command tmux list-windows -F '#{window_name}' 2>/dev/null | grep -cx "$WINDOW_NAME")
if [ "$HAS_WINDOW" -eq 0 ]; then
  command tmux new-window -d -n "$WINDOW_NAME" "$STARTER"
  command tmux select-window -t ":$WINDOW_NAME"
fi
