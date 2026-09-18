#!/usr/bin/env bash
# Compact workmux agent summary for the tmux status line.
#
# Prints one line of colour-coded counts: ▲ agents waiting for input,
# ● agents working, ✓ agents done. Counts are global (all tmux sessions of
# this server), matching what `workmux dashboard` shows when the segment is
# clicked. "–" means no tracked agents, "?" means workmux could not be
# queried — never an error string, since this lands in the status bar.
#
# Only foreground colours are emitted so the surrounding catppuccin module
# keeps control of the background and attributes.

set -uo pipefail

# Status-line jobs inherit the focused pane's working directory. Inside a git
# repo `workmux status` scopes itself to that repository and reports no agents
# at all, so query from a neutral directory to keep the counts server-global.
cd / || exit 0

# Palette from catppuccin, so the segment follows @catppuccin_flavor.
if ! read -r c_wait c_work c_done c_idle <<<"$(
  tmux display-message -p \
    '#{E:@thm_peach} #{E:@thm_sapphire} #{E:@thm_green} #{E:@thm_overlay1}' 2>/dev/null
)"; then
  c_wait= c_work= c_done= c_idle=
fi
: "${c_wait:=#fab387}" "${c_work:=#74c7ec}" "${c_done:=#a6e3a1}" "${c_idle:=#7f849c}"

# Constant cell width for the rendered counts (see the render block below).
WIDTH=9

unknown() { printf '#[fg=%s]?%*s' "$c_idle" "$((WIDTH - 1))" ''; exit 0; }

command -v workmux >/dev/null 2>&1 || unknown
command -v jq >/dev/null 2>&1 || unknown

json=$(workmux status --json 2>/dev/null) && [ -n "$json" ] || unknown

counts=$(
  printf '%s' "$json" | jq -r '
    [.agents[]?.status] as $s
    | [ ($s | map(select(. == "waiting")) | length),
        ($s | map(select(. == "working")) | length),
        ($s | map(select(. == "done"))    | length) ]
    | join(" ")' 2>/dev/null
) || unknown

read -r waiting working finished <<<"$counts"
[ -n "${finished:-}" ] || unknown

# The bar is right-aligned, so any width change here shifts every segment to
# the left of it — that is the flicker. Render to the constant WIDTH instead:
# cells is tracked as the output is built (digits are ASCII, so no
# locale-dependent string width), then padded out.
out="" cells=0

bucket() { # colour glyph count
  out="${out}#[fg=${1}]${2}${3} "
  cells=$((cells + 2 + ${#3}))
}

[ "$waiting" -gt 0 ] && bucket "$c_wait" "▲" "$waiting"
[ "$working" -gt 0 ] && bucket "$c_work" "●" "$working"
[ "$finished" -gt 0 ] && bucket "$c_done" "✓" "$finished"
[ "$cells" -gt 0 ] || bucket "$c_idle" "–" ""

pad=$((WIDTH - cells + 1)) # +1 for the trailing space kept below
[ "$pad" -lt 0 ] && pad=0

printf '%s%*s' "${out% }" "$pad" ''
