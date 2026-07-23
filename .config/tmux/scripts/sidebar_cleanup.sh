#!/usr/bin/env bash
# Remove leftover workmux sidebar panes after a tmux-resurrect/continuum restore.
#
# The workmux sidebar adds a narrow full-height pane to the left of each window.
# tmux-resurrect saves those panes; on restore the workmux process is gone, so
# they come back as dead empty shells. This script kills those leftovers so
# restored sessions don't keep unnecessary sidebar splits.
#
# It is deliberately conservative:
#   * runs at most once per tmux server (guarded by @sidebar_cleanup_done);
#   * does nothing while a live sidebar is active (@workmux_sidebar_enabled);
#   * only kills a pane that matches the sidebar signature — left edge,
#     full window height, narrow, bare login shell, in a multi-pane window.

tmux_bin=$(command -v tmux 2>/dev/null || true)
[ -n "$tmux_bin" ] || tmux_bin=tmux

# Give continuum's restore a moment to finish materialising panes.
sleep 3

# Never touch a live sidebar (workmux sets this option while it is active).
# Exit without marking done, so cleanup still runs on a later attach once the
# sidebar is toggled off.
[ "$("$tmux_bin" show-option -gqv @workmux_sidebar_enabled)" = "1" ] && exit 0

# Otherwise run at most once per server.
[ "$("$tmux_bin" show-option -gqv @sidebar_cleanup_done)" = "1" ] && exit 0
"$tmux_bin" set -g @sidebar_cleanup_done 1

"$tmux_bin" list-panes -a -F \
  '#{pane_id}|#{pane_left}|#{pane_top}|#{pane_width}|#{pane_height}|#{window_height}|#{window_panes}|#{pane_current_command}' \
2>/dev/null | while IFS='|' read -r id left top width height wheight wpanes cmd; do
  [ "$left" = "0" ] || continue                       # left edge only
  [ "$top" = "0" ]  || continue                       # top-aligned
  [ "$height" = "$wheight" ] || continue              # spans full window height (a column, not a row split)
  [ "${wpanes:-0}" -gt 1 ] 2>/dev/null || continue    # window has other panes
  [ "${width:-999}" -le 50 ] 2>/dev/null || continue  # narrow (workmux clamps the left sidebar to <=50)
  case "$cmd" in
    zsh|bash|sh|fish|-zsh|-bash) ;;                    # a bare shell (the sidebar process is gone)
    *) continue ;;
  esac
  "$tmux_bin" kill-pane -t "$id" 2>/dev/null
done

exit 0
