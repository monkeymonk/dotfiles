#!/usr/bin/env bash
# Screensaver wrapper — any keypress dismisses.

CMD=$(command tmux show-option -gqv @screensaver_cmd 2>/dev/null)
CMD=${CMD:-"cmatrix -ab -u 5"}

# Hide status bar for full immersion
command tmux set status off

# Run cmatrix without stdin so it only renders
eval "$CMD" </dev/null &
PID=$!

# Any keypress kills the screensaver
read -rsn1

kill "$PID" 2>/dev/null
wait "$PID" 2>/dev/null

# Restore status bar
command tmux set status on
