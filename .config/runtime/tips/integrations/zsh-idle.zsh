# tips — idle-time tip display for zsh.
#
# Shows a tip below the prompt after a period of idle time at an empty prompt.
# Tip is cleared on keystroke, command execution, or directory change.
# Press Alt+k to copy the visible tip into the edit buffer.
#
# Source this file from your .zshrc *after* sourcing tips.sh:
#
#   source ~/.local/bin/tips.sh
#   source "$TIPS_CONFIG_DIR/integrations/zsh-idle.zsh"
#
# Settings (set before sourcing this file):
#   TIPS_IDLE_INTERVAL    seconds between tip rotations (default: 8)
#   TIPS_IDLE_COLOR       fg color number, e.g. 244 (default: 244)
#   TIPS_IDLE_PREFIX      prefix glyph (default: "⎿ ")
#   TIPS_IDLE_APPLY_KEY   keybinding to copy tip to buffer (default: Alt+k)

[[ -n "$ZSH_VERSION" ]] || return 0
command -v tips >/dev/null 2>&1 || return 0

: "${TIPS_IDLE_INTERVAL:=8}"
: "${TIPS_IDLE_COLOR:=244}"
: "${TIPS_IDLE_PREFIX:=⎿ }"
: "${TIPS_IDLE_APPLY_KEY:=\ek}"

autoload -Uz add-zsh-hook add-zle-hook-widget

_tips_idle_current=""
_tips_idle_visible=0
_tips_idle_highlight=""
_tips_idle_last_activity=$SECONDS
_tips_idle_timer_fd=""

_tips_idle_pick() {
  _tips_idle_current="$(tips 2>/dev/null)"
}

_tips_idle_draw() {
  [[ -n "$BUFFER" ]] && return
  [[ -n "$_tips_idle_current" ]] || return
  local line="${TIPS_IDLE_PREFIX}${_tips_idle_current}"
  POSTDISPLAY=$'\n'"$line"
  local start=$(( ${#BUFFER} + 1 ))
  local end=$(( start + ${#line} ))
  [[ -n "$_tips_idle_highlight" ]] && \
    region_highlight=("${(@)region_highlight:#$_tips_idle_highlight}")
  _tips_idle_highlight="$start $end fg=${TIPS_IDLE_COLOR}"
  region_highlight+=("$_tips_idle_highlight")
  _tips_idle_visible=1
  zle -R
}

_tips_idle_clear() {
  (( _tips_idle_visible )) || return
  POSTDISPLAY=""
  [[ -n "$_tips_idle_highlight" ]] && \
    region_highlight=("${(@)region_highlight:#$_tips_idle_highlight}")
  _tips_idle_highlight=""
  _tips_idle_visible=0
}

_tips_idle_handler() {
  local dummy
  read -ru "$_tips_idle_timer_fd" dummy 2>/dev/null || { zle -F "$_tips_idle_timer_fd"; return; }
  while read -ru "$_tips_idle_timer_fd" -t 0 dummy 2>/dev/null; do :; done
  [[ -z "$BUFFER" ]] || return
  if [[ -n "${TMUX-}" ]]; then
    local active
    active=$(tmux display-message -p -t "$TMUX_PANE" '#{&&:#{pane_active},#{window_active}}' 2>/dev/null)
    [[ "$active" == "1" ]] || return
  fi
  local elapsed=$(( SECONDS - _tips_idle_last_activity ))
  (( elapsed < 2 )) && return
  _tips_idle_pick
  _tips_idle_draw
}
zle -N _tips_idle_handler

_tips_idle_init_timer() {
  [[ -n "$_tips_idle_timer_fd" ]] && return
  exec {_tips_idle_timer_fd}< <(
    trap 'exit 0' TERM HUP
    while true; do sleep "$TIPS_IDLE_INTERVAL"; printf 'x\n'; done
  )
  zle -Fw "$_tips_idle_timer_fd" _tips_idle_handler
}

_tips_idle_cleanup() {
  [[ -n "$_tips_idle_timer_fd" ]] || return
  zle -F "$_tips_idle_timer_fd" 2>/dev/null
  exec {_tips_idle_timer_fd}<&- 2>/dev/null
  _tips_idle_timer_fd=""
}
add-zsh-hook zshexit _tips_idle_cleanup

_tips_idle_on_init()   { _tips_idle_init_timer }
_tips_idle_on_finish() { _tips_idle_clear }
_tips_idle_guard() {
  _tips_idle_last_activity=$SECONDS
  [[ -n "$BUFFER" ]] && _tips_idle_clear
}
add-zle-hook-widget line-init       _tips_idle_on_init
add-zle-hook-widget line-pre-redraw _tips_idle_guard
add-zle-hook-widget line-finish     _tips_idle_on_finish

_tips_idle_apply() {
  [[ -n "$_tips_idle_current" ]] || return
  _tips_idle_clear
  BUFFER="$_tips_idle_current"
  CURSOR=${#BUFFER}
}
zle -N _tips_idle_apply
bindkey "$TIPS_IDLE_APPLY_KEY" _tips_idle_apply
