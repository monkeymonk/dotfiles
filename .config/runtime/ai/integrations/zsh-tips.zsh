# ===== CONFIG =====
ZSH_TIPS_INTERVAL=8
ZSH_TIPS_COLOR=244
ZSH_TIPS_PREFIX="⎿ "
ZSH_TIPS_DYNAMIC_PREFIX="⎿ 🤖 "
ZSH_TIPS_DYNAMIC_WEIGHT=70   # % chance to pick a dynamic tip when available
ZSH_TIPS_FILE="${RUNTIME_ROOT:-$HOME/.config/runtime}/ai/data/tips.txt"
ZSH_TIPS_APPLY_KEY="${ZSH_TIPS_APPLY_KEY:-\ek}"  # Alt+k to apply tip to edit line

# Dynamic tips via pluggable generator (opt-in)
# Generator must: take dir as $1, output tips to stdout, exit 0 on success
: "${ZSH_TIPS_DYNAMIC:=1}"
: "${ZSH_TIPS_DYNAMIC_TTL:=3600}"
: "${ZSH_TIPS_GENERATOR:=tips-generate-ollama}"

# Debug: ZSH_TIPS_DEBUG=1 to log generation details to ~/.cache/runtime/tips-debug.log
: "${ZSH_TIPS_DEBUG:=0}"
ZSH_TIPS_DEBUG_LOG="${XDG_CACHE_HOME:-$HOME/.cache}/runtime/tips-debug.log"

_zsh_tips_dbg() {
  (( ZSH_TIPS_DEBUG )) || return 0
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >> "$ZSH_TIPS_DEBUG_LOG"
}

# ===== TIP LOADING =====

_zsh_tips_load_static() {
  ZSH_TIPS_STATIC=()
  [[ -r "$ZSH_TIPS_FILE" ]] || return 0
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    ZSH_TIPS_STATIC+=("$line")
  done < "$ZSH_TIPS_FILE"
}

_zsh_tips_load_dynamic() {
  ZSH_TIPS_DYNAMIC_LIST=()
  (( ZSH_TIPS_DYNAMIC )) || return 0
  command -v cache-run >/dev/null 2>&1 || return 0

  local hash cache_dir cache_file
  cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/runtime/cache-run"
  hash=$(printf '%s' "tips:$PWD" | md5sum 2>/dev/null | cut -d' ' -f1)
  [[ -z "$hash" ]] && hash=$(printf '%s' "tips:$PWD" | md5 -q 2>/dev/null)
  cache_file="$cache_dir/$hash"

  [[ -r "$cache_file" ]] || return 0
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    ZSH_TIPS_DYNAMIC_LIST+=("$line")
  done < "$cache_file"
}

_zsh_tips_generate_bg() {
  (( ZSH_TIPS_DYNAMIC )) || return 0
  command -v cache-run >/dev/null 2>&1 || return 0
  command -v "$ZSH_TIPS_GENERATOR" >/dev/null 2>&1 || return 0

  _zsh_tips_dbg "generate_bg: dir=$PWD generator=$ZSH_TIPS_GENERATOR"

  (
    cache-run --bg "tips:$PWD" "$ZSH_TIPS_DYNAMIC_TTL" \
      "$ZSH_TIPS_GENERATOR" "$PWD"
  ) >/dev/null 2>&1 &!
}

# ===== INIT =====

_zsh_tips_load_static
_zsh_tips_dbg "static tips loaded: ${#ZSH_TIPS_STATIC[@]}"
_zsh_tips_load_dynamic
_zsh_tips_dbg "dynamic tips loaded: ${#ZSH_TIPS_DYNAMIC_LIST[@]}"

autoload -Uz add-zsh-hook

if (( ZSH_TIPS_DYNAMIC )); then
  _zsh_tips_chpwd() {
    _zsh_tips_dbg "chpwd: $PWD"
    _zsh_tips_generate_bg
    _zsh_tips_load_dynamic
    _zsh_tips_dbg "dynamic tips after chpwd: ${#ZSH_TIPS_DYNAMIC_LIST[@]}"
  }
  add-zsh-hook chpwd _zsh_tips_chpwd
  # Generate for initial directory
  _zsh_tips_dbg "init: generating for $PWD"
  _zsh_tips_generate_bg
fi

# ===== DISPLAY =====

_zsh_tip_current=""
_zsh_tip_current_prefix=""
_zsh_tip_visible=0
_zsh_tip_highlight_entry=""
_zsh_tip_last_activity=$SECONDS

# Weighted random: prefer dynamic tips when available
_zsh_tip_rotate() {
  local use_dynamic=0
  local n_static=${#ZSH_TIPS_STATIC[@]}
  local n_dynamic=${#ZSH_TIPS_DYNAMIC_LIST[@]}

  if (( n_dynamic > 0 && n_static > 0 )); then
    (( RANDOM % 100 < ZSH_TIPS_DYNAMIC_WEIGHT )) && use_dynamic=1
  elif (( n_dynamic > 0 )); then
    use_dynamic=1
  fi

  if (( use_dynamic )); then
    _zsh_tip_current=${ZSH_TIPS_DYNAMIC_LIST[$RANDOM % n_dynamic + 1]}
    _zsh_tip_current_prefix="$ZSH_TIPS_DYNAMIC_PREFIX"
  elif (( n_static > 0 )); then
    _zsh_tip_current=${ZSH_TIPS_STATIC[$RANDOM % n_static + 1]}
    _zsh_tip_current_prefix="$ZSH_TIPS_PREFIX"
  else
    _zsh_tip_current="No tips loaded"
    _zsh_tip_current_prefix="$ZSH_TIPS_PREFIX"
  fi
}

_zsh_tip_draw() {
  [[ -n "$BUFFER" ]] && return
  local tip="${_zsh_tip_current_prefix}${_zsh_tip_current}"
  POSTDISPLAY=$'\n'"$tip"
  # Color the tip via region_highlight (positions relative to PREDISPLAY+BUFFER+POSTDISPLAY)
  local start=$(( ${#BUFFER} + 1 ))  # +1 to skip the \n
  local end=$(( start + ${#tip} ))
  # Remove only OUR previous highlight entry (not other plugins')
  [[ -n "$_zsh_tip_highlight_entry" ]] && \
    region_highlight=("${(@)region_highlight:#$_zsh_tip_highlight_entry}")
  _zsh_tip_highlight_entry="$start $end fg=${ZSH_TIPS_COLOR}"
  region_highlight+=("$_zsh_tip_highlight_entry")
  _zsh_tip_visible=1
  zle -R
}

_zsh_tip_clear() {
  (( _zsh_tip_visible )) || return
  POSTDISPLAY=""
  # Remove only OUR highlight entry by exact match
  [[ -n "$_zsh_tip_highlight_entry" ]] && \
    region_highlight=("${(@)region_highlight:#$_zsh_tip_highlight_entry}")
  _zsh_tip_highlight_entry=""
  _zsh_tip_visible=0
}

# ===== TIMER (zle -Fw pipe, replaces TMOUT/TRAPALRM) =====
# TMOUT/TRAPALRM causes implicit ZLE redraws on every fire.
# zle -Fw registers the handler as a proper widget with full BUFFER access.

_zsh_tip_timer_fd=""

_zsh_tip_handler() {
  local dummy
  read -ru $_zsh_tip_timer_fd dummy 2>/dev/null || { zle -F "$_zsh_tip_timer_fd"; return; }
  [[ -z "$BUFFER" ]] || return
  # Don't interfere if user was recently active (e.g. navigating history)
  local elapsed=$(( SECONDS - _zsh_tip_last_activity ))
  (( elapsed < 2 )) && return
  # Pick up newly generated dynamic tips once cache-run finishes
  (( ZSH_TIPS_DYNAMIC )) && (( ${#ZSH_TIPS_DYNAMIC_LIST[@]} == 0 )) && {
    _zsh_tips_load_dynamic
    _zsh_tips_dbg "timer reload: ${#ZSH_TIPS_DYNAMIC_LIST[@]} dynamic tips"
  }
  _zsh_tip_rotate
  _zsh_tip_draw
}
zle -N _zsh_tip_handler

_zsh_tip_init_timer() {
  [[ -n "$_zsh_tip_timer_fd" ]] && return
  exec {_zsh_tip_timer_fd}< <(
    trap 'exit 0' TERM HUP
    while true; do
      sleep "$ZSH_TIPS_INTERVAL"
      printf 'x\n'
    done
  )
  zle -Fw "$_zsh_tip_timer_fd" _zsh_tip_handler
}

_zsh_tip_cleanup() {
  [[ -n "$_zsh_tip_timer_fd" ]] || return
  zle -F "$_zsh_tip_timer_fd" 2>/dev/null
  exec {_zsh_tip_timer_fd}<&- 2>/dev/null
  _zsh_tip_timer_fd=""
}

add-zsh-hook zshexit _zsh_tip_cleanup

# ===== ZLE HOOKS =====

# Start timer once ZLE is ready
_zsh_tip_on_init() { _zsh_tip_init_timer }

# Clear tip immediately when user types; track activity for debounce
_zsh_tip_guard() {
  _zsh_tip_last_activity=$SECONDS
  [[ -n "$BUFFER" ]] && _zsh_tip_clear
}

# Clear tip before command execution
_zsh_tip_on_finish() { _zsh_tip_clear }

autoload -Uz add-zle-hook-widget
add-zle-hook-widget line-init _zsh_tip_on_init
add-zle-hook-widget line-pre-redraw _zsh_tip_guard
add-zle-hook-widget line-finish _zsh_tip_on_finish

# ===== APPLY TIP TO EDIT LINE (Alt+k) =====

_zsh_tip_apply() {
  [[ -n "$_zsh_tip_current" ]] || return
  _zsh_tip_clear
  BUFFER="$_zsh_tip_current"
  CURSOR=${#BUFFER}
}
zle -N _zsh_tip_apply
bindkey "$ZSH_TIPS_APPLY_KEY" _zsh_tip_apply
