#!/usr/bin/env bash
# Screensaver wrapper — randomly picks a screensaver command.

PBC_BIN="$HOME/works/tools/pbc/target/release/pbc"
# GOL_BIN="$HOME/works/tools/gol/target/release/gol"

# Build command pool: "fg:cmd" runs foreground, "bg:cmd" runs background+keypress dismiss
POOL=()
if [ -x "$PBC_BIN" ]; then
  POOL+=("fg:$PBC_BIN --effect physics --screensaver")
  POOL+=("fg:$PBC_BIN --effect encrypt --screensaver")
  POOL+=("fg:$PBC_BIN --effect vanish --screensaver")
fi
# if [ -x "$GOL_BIN" ]; then
#   POOL+=("fg:$GOL_BIN --demo --screensaver")
# fi
# POOL+=("bg:cmatrix -ab -u 5")

# Pick random
CHOICE="${POOL[$((RANDOM % ${#POOL[@]}))]}"
TYPE="${CHOICE%%:*}"
CMD="${CHOICE#*:}"

# Hide status bar
command tmux set status off

if [ "$TYPE" = "fg" ]; then
  eval "$CMD"
else
  eval "$CMD" </dev/null &
  PID=$!
  read -rsn1
  kill "$PID" 2>/dev/null
  wait "$PID" 2>/dev/null
fi

# Restore status bar
command tmux set status on
