#!/usr/bin/env bash
# Screensaver check — called by tmux status-right #()
# Runs once per status-interval, no loops, no daemons.

LIMIT=$(command tmux show-option -gqv @screensaver_idle 2>/dev/null)
LIMIT=${LIMIT:-300}

WINDOW_NAME=$(command tmux show-option -gqv @screensaver_window 2>/dev/null)
WINDOW_NAME=${WINDOW_NAME:-matrix}

STARTER="$HOME/.config/tmux/screensaver/start.sh"

# Compute idle from client_activity (epoch timestamp, universally supported)
ACTIVITY=$(command tmux list-clients -F '#{client_activity}' 2>/dev/null | sort -rn | head -1)
[ -z "$ACTIVITY" ] && exit 0

NOW=$(date +%s)
IDLE=$((NOW - ACTIVITY))

HAS_WINDOW=$(command tmux list-windows -F '#{window_name}' 2>/dev/null | grep -cx "$WINDOW_NAME")

if [ "$IDLE" -ge "$LIMIT" ]; then
  if [ "$HAS_WINDOW" -eq 0 ]; then
    command tmux new-window -d -n "$WINDOW_NAME" "$STARTER"
    command tmux select-window -t ":$WINDOW_NAME"
  fi
fi
