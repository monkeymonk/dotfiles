#!/usr/bin/env bash
# Toggle the workmux dashboard in a centred floating pane.
#
# A floating pane (tmux 3.7+) is used instead of display-popup on purpose: a
# popup is a modal overlay, so while it is open tmux swallows every mouse event
# outside it and a second click on the status segment never reaches the binding
# that would close it. A floating pane is an ordinary pane, so the click
# toggles, while the dashboard keeps its popup-like framing.
#
# The pane is found by its title rather than a stored id, which keeps the
# toggle stateless and self-healing across server restarts.
#
#   workmux_dashboard.sh          toggle
#   workmux_dashboard.sh --close  close only (used by the client-detached hook)

set -uo pipefail

TITLE="wmx-dashboard"

open=$(tmux list-panes -a -F '#{pane_id} #{pane_title}' |
  awk -v t="$TITLE" '$2 == t { print $1 }')

if [ -n "$open" ]; then
  for id in $open; do tmux kill-pane -t "$id" 2>/dev/null; done
  exit 0
fi

[ "${1:-}" = "--close" ] && exit 0

# new-pane takes absolute cells and has no centring flag, so place it here.
read -r ww wh <<<"$(tmux display-message -p '#{window_width} #{window_height}')"
[ -n "${wh:-}" ] || exit 0

w=$((ww * 90 / 100))
h=$((wh * 85 / 100))
[ "$w" -lt 40 ] && w=$ww
[ "$h" -lt 10 ] && h=$wh
x=$(((ww - w) / 2))
y=$(((wh - h) / 2))

id=$(tmux new-pane -P -F '#{pane_id}' -x "$w" -y "$h" -X "$x" -Y "$y" \
  workmux dashboard) || exit 0
tmux select-pane -t "$id" -T "$TITLE"
