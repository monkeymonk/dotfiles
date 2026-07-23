#!/usr/bin/env bash
# Dynamic tmux binding help panel.
#
# Source of truth: `tmux list-keys -N`. Bindings are documented in tmux.conf
# with notes of the form:
#
#     bind-key -N "Category | Description" <key> <command>
#
# This script only DISPLAYS bindings; it never executes the selected one.

set -euo pipefail

# Resolve the tmux binary directly (avoid interactive shell aliases/functions).
TMUX_BIN=$(command -v tmux 2>/dev/null || true)
[ -n "$TMUX_BIN" ] || TMUX_BIN=tmux

# Detect the configured prefix dynamically (no hardcoded C-a).
PREFIX=$("$TMUX_BIN" show-options -gv prefix 2>/dev/null || true)
[ -n "$PREFIX" ] || PREFIX="C-a"

# Extract bindings from one key table into TSV columns:
#   category <TAB> displayed-key <TAB> description <TAB> table
#
# mode=prefix -> render key with the prefix, e.g. "C-a h"
# mode=root   -> render key bare,            e.g. "M-T"
# require=1   -> include only notes using the "Category | Description"
#               convention. This is always on: it keeps the index to the
#               bindings I have deliberately annotated and drops the dozens of
#               tmux/plugin defaults that ship their own plain notes.
extract() {
  local table="$1" mode="$2" require="$3"
  "$TMUX_BIN" list-keys -N -T "$table" 2>/dev/null | awk \
    -v OFS='\t' -v pfx="$PREFIX" -v tbl="$table" -v mode="$mode" -v req="$require" '
    {
      key = $2
      note = $0
      # list-keys -N prints "<prefix-token> <key-token><padding><note>" for
      # every table. Strip those two leading tokens regardless of padding,
      # leaving just the note text.
      sub(/^[^ ]+[ ]+[^ ]+[ ]+/, "", note)
      d = index(note, " | ")
      if (d > 0) {
        cat  = substr(note, 1, d - 1)
        desc = substr(note, d + 3)
      } else {
        if (req == "1") next
        cat  = "Other"
        desc = note
      }
      if (cat == "")  cat  = "Other"
      if (desc == "") next
      disp = (mode == "prefix") ? pfx " " key : key
      print cat, disp, desc, tbl
    }'
}

# Category display order (anything unlisted sorts last, alphabetically).
CAT_ORDER="Sessions|Windows|Navigation|Panes|Copy mode|Persistence|Configuration|Utilities|Plugins|Workmux|Help"

# Collect annotated bindings from every relevant table, then order them by
# category rank and key so related bindings stay grouped.
data=$(
  {
    extract prefix        prefix 1
    extract root          root   1
    extract copy-mode-vi  copy   1
  } | awk -F'\t' -v OFS='\t' -v order="$CAT_ORDER" '
      BEGIN { n = split(order, a, "|"); for (i = 1; i <= n; i++) rank[a[i]] = i }
      { r = ($1 in rank) ? rank[$1] : 99; printf "%02d\t%s\t%s\t%s\t%s\n", r, $1, $2, $3, $4 }' \
  | sort -t "$(printf '\t')" -k1,1n -k2,2 -k3,3 \
  | cut -f2-
)

if [ -z "$data" ]; then
  printf 'No annotated tmux bindings found.\n'
  printf 'Add notes like:  bind-key -N "Sessions | New session" S ...\n'
  exit 0
fi

# Detect the popup width so the grid can pick a sensible column count.
width=$(stty size </dev/tty 2>/dev/null | awk '{ print $2 }')
case "$width" in ''|*[!0-9]*) width=$(tput cols 2>/dev/null || echo 90) ;; esac
[ "${width:-0}" -ge 40 ] 2>/dev/null || width=90

# Widest key, used for column alignment.
keyw=$(printf '%s\n' "$data" | awk -F'\t' '{ if (length($2) > m) m = length($2) } END { print m + 0 }')

# Render a category-grouped grid: a "── Category ──" divider, then that
# category's bindings packed into aligned columns. Colour-free — fzf/tmux
# handle appearance. A search query matches a whole grid row.
grid=$(printf '%s\n' "$data" | awk -F'\t' -v W="$width" -v keyw="$keyw" '
  function divider(c,   s, n, i) {
    s = "── " c " "
    n = W - length(s)
    for (i = 0; i < n; i++) s = s "─"
    return s
  }
  function cell(k, d,   dd, pad) {
    dd = d
    if (length(dd) > descw) { dd = substr(dd, 1, descw - 1) "…"; pad = 0 }
    else pad = descw - length(dd)
    return sprintf("%-*s %s%*s", keyw, k, dd, pad, "")
  }
  BEGIN {
    gutter = 2
    cols = int((W + gutter) / (keyw + 1 + 16 + gutter))
    if (cols < 1) cols = 1
    if (cols > 3) cols = 3
    descw = int((W - cols * (keyw + 1) - (cols - 1) * gutter) / cols)
    if (descw < 10) descw = 10
  }
  {
    if ($1 != cur) {
      if (n > 0) { print row; row = ""; n = 0 }
      print divider($1)
      cur = $1
    }
    c = cell($2, $3)
    row = (n == 0) ? c : row sprintf("%*s", gutter, "") c
    if (++n == cols) { print row; row = ""; n = 0 }
  }
  END { if (n > 0) print row }
')

if command -v fzf >/dev/null 2>&1; then
  # Informational picker. The selection is deliberately discarded — this panel
  # never runs a binding.
  printf '%s\n' "$grid" | fzf \
    --layout=reverse \
    --no-sort \
    --info=inline \
    --prompt 'bindings> ' \
    --header "Prefix: ${PREFIX}   ·   type to filter   ·   Esc / Ctrl-c closes" \
    --bind 'esc:abort,ctrl-c:abort' \
    >/dev/null 2>&1 || true
else
  printf '%s\n' "$grid" | less -R
fi

exit 0
