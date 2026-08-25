#!/usr/bin/env bash
# tips — extensible tip aggregator with pluggable providers

__TIPS_VERSION="0.1.0"
__TIPS_PROVIDERS=()

# ===== CONFIG DEFAULTS =====
# When XDG_* vars are set, follow the XDG Base Directory spec.
# Otherwise, unify everything under $TIPS_CONFIG_DIR for easy discovery.

: "${TIPS_CONFIG_DIR:=${XDG_CONFIG_HOME:-$HOME/.config}/tips}"
if [[ -n "${XDG_DATA_HOME:-}" ]]; then
  : "${TIPS_DATA_DIR:=$XDG_DATA_HOME/tips}"
else
  : "${TIPS_DATA_DIR:=$TIPS_CONFIG_DIR/data}"
fi
if [[ -n "${XDG_CACHE_HOME:-}" ]]; then
  : "${TIPS_CACHE_DIR:=$XDG_CACHE_HOME/tips}"
else
  : "${TIPS_CACHE_DIR:=$TIPS_CONFIG_DIR/cache}"
fi
: "${TIPS_DATA_FILE:=$TIPS_DATA_DIR/tips.txt}"

# ===== INTERNAL HELPERS =====

_tips_usage() {
  printf "tips — extensible tip aggregator\nVersion: v%s\n\n" "$__TIPS_VERSION"
  cat <<'USAGE'
Usage:
  tips [command] [options]

Commands:
  (none)                Show a random tip
  list [--source X]     List all tips (optionally filter by provider)
  count [--source X]    Count tips per provider
  refresh [--source X]  Regenerate tips (providers that support it)
  status                Show providers, counts, config
  sources               List registered providers
  edit [provider]       Open tip source in $EDITOR (default: static)
  help                  Show this help
  version               Show version

Options:
  -h, --help            Show this help
  -v, --version         Show version
USAGE
}

# Resolve installation directory at source/load time
# For zsh: capture at top level since ${(%):-%x} only works at source-time
if [[ -n "${ZSH_VERSION:-}" ]]; then
  __TIPS_DIR="${${(%):-%x}:A:h}"
elif [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  __TIPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  __TIPS_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# ===== PROVIDER SYSTEM =====

tips_register_provider() {
  local name="$1"
  # Dedup
  [[ " ${__TIPS_PROVIDERS[*]} " == *" $name "* ]] && return 0
  __TIPS_PROVIDERS+=("$name")
}

# Call a provider method: _tips_pcall <provider> <method> [args...]
_tips_pcall() {
  local name="$1" method="$2"
  shift 2
  local fn="tips_provider_${name}_${method}"
  if declare -F "$fn" &>/dev/null; then
    "$fn" "$@"
    return $?
  fi
  return 1
}

_tips_pweight() {
  local w
  w=$(_tips_pcall "$1" weight 2>/dev/null) || w=50
  echo "$w"
}

_tips_pname() {
  local n
  n=$(_tips_pcall "$1" name 2>/dev/null) || n="$1"
  echo "$n"
}

_tips_pcount() {
  local output
  output=$(_tips_pcall "$1" list 2>/dev/null) || { echo 0; return; }
  if [[ -z "$output" ]]; then
    echo 0
  else
    echo "$output" | wc -l | tr -d ' '
  fi
}

# ===== INIT =====

_tips_init() {
  __TIPS_PROVIDERS=()

  # Source global config
  [[ -f "$TIPS_CONFIG_DIR/config.sh" ]] && source "$TIPS_CONFIG_DIR/config.sh"

  # Load built-in providers
  local f
  if [[ -d "$__TIPS_DIR/providers" ]]; then
    for f in "$__TIPS_DIR/providers"/*.sh; do
      if [[ -f "$f" ]]; then source "$f"; fi
    done
  fi

  # Load user providers
  if [[ -d "$TIPS_CONFIG_DIR/providers" ]]; then
    for f in "$TIPS_CONFIG_DIR/providers"/*.sh; do
      if [[ -f "$f" ]]; then source "$f"; fi
    done
  fi
}

# ===== COMMANDS =====

_tips_cmd_random() {
  # Weighted provider selection, then random tip from that provider
  local total_weight=0
  local name w cnt
  local -a eligible=()

  for name in "${__TIPS_PROVIDERS[@]}"; do
    w=$(_tips_pweight "$name")
    (( w == 0 )) && continue
    cnt=$(_tips_pcount "$name")
    (( cnt == 0 )) && continue
    eligible+=("$name:$w")
    total_weight=$((total_weight + w))
  done

  if (( total_weight == 0 )); then
    echo "No tips available." >&2
    return 1
  fi

  # Pick provider by weight (no index-based access — works in both bash and zsh)
  local roll=$(( RANDOM % total_weight ))
  local acc=0 picked="" entry pw
  for entry in "${eligible[@]}"; do
    pw="${entry##*:}"
    acc=$(( acc + pw ))
    if (( roll < acc )); then
      picked="${entry%:*}"
      break
    fi
  done
  [[ -z "$picked" ]] && picked="${eligible[-1]%:*}"

  # Random tip from picked provider
  local output count idx
  output=$(_tips_pcall "$picked" list 2>/dev/null) || return 1
  count=$(echo "$output" | wc -l | tr -d ' ')
  idx=$(( RANDOM % count + 1 ))
  echo "$output" | sed -n "${idx}p"
}

_tips_cmd_list() {
  local filter="" name display count output
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --source) filter="${2:-}"; shift 2 ;;
      *) shift ;;
    esac
  done

  for name in "${__TIPS_PROVIDERS[@]}"; do
    [[ -n "$filter" && "$name" != "$filter" ]] && continue
    display=$(_tips_pname "$name")
    output=$(_tips_pcall "$name" list 2>/dev/null) || continue
    [[ -z "$output" ]] && continue
    count=$(echo "$output" | wc -l | tr -d ' ')
    printf "\033[1m[%s]\033[0m (%d tips)\n" "$display" "$count"
    echo "$output" | while IFS= read -r line; do
      [[ -n "$line" ]] && echo "  $line"
    done
    echo
  done
}

_tips_cmd_count() {
  local filter="" total=0 name display cnt
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --source) filter="${2:-}"; shift 2 ;;
      *) shift ;;
    esac
  done

  for name in "${__TIPS_PROVIDERS[@]}"; do
    [[ -n "$filter" && "$name" != "$filter" ]] && continue
    display=$(_tips_pname "$name")
    cnt=$(_tips_pcount "$name")
    total=$((total + cnt))
    printf "%4d  %s\n" "$cnt" "$display"
  done
  if [[ -z "$filter" ]] && (( ${#__TIPS_PROVIDERS[@]} > 1 )); then
    printf "%4d  total\n" "$total"
  fi
}

_tips_cmd_refresh() {
  local filter="" name display
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --source) filter="${2:-}"; shift 2 ;;
      *) shift ;;
    esac
  done

  for name in "${__TIPS_PROVIDERS[@]}"; do
    [[ -n "$filter" && "$name" != "$filter" ]] && continue
    display=$(_tips_pname "$name")
    if _tips_pcall "$name" generate "$PWD" 2>/dev/null; then
      echo "✓ $display: refreshed"
    else
      echo "- $display: no generator"
    fi
  done
}

_tips_cmd_status() {
  printf "tips v%s\n\n" "$__TIPS_VERSION"
  printf "Config dir:   %s\n" "$TIPS_CONFIG_DIR"
  printf "Data dir:     %s\n" "$TIPS_DATA_DIR"
  printf "Cache dir:    %s\n" "$TIPS_CACHE_DIR"
  [[ -d "$__TIPS_DIR/providers" ]] && \
    printf "Built-in dir: %s/providers/\n" "$__TIPS_DIR"
  printf "User dir:     %s/providers/\n" "$TIPS_CONFIG_DIR"
  printf "Data file:    %s\n\n" "$TIPS_DATA_FILE"

  local name display w cnt status_output
  printf "\033[1mProviders:\033[0m\n"
  for name in "${__TIPS_PROVIDERS[@]}"; do
    display=$(_tips_pname "$name")
    w=$(_tips_pweight "$name")
    cnt=$(_tips_pcount "$name")
    printf "  %-12s  weight=%-3d  tips=%d\n" "$display" "$w" "$cnt"
    status_output=$(_tips_pcall "$name" status 2>/dev/null)
    if [[ -n "$status_output" ]]; then
      echo "$status_output" | while IFS= read -r line; do
        printf "    %s\n" "$line"
      done
    fi
  done
}

_tips_cmd_sources() {
  local name display w
  for name in "${__TIPS_PROVIDERS[@]}"; do
    display=$(_tips_pname "$name")
    w=$(_tips_pweight "$name")
    printf "%-12s  %s  (weight: %d)\n" "$name" "$display" "$w"
  done
}

_tips_cmd_edit() {
  local provider="${1:-static}"
  local file
  file=$(_tips_pcall "$provider" edit_path 2>/dev/null)
  if [[ -z "$file" ]]; then
    echo "tips: provider '$provider' has no editable file" >&2
    return 1
  fi
  if [[ ! -f "$file" ]]; then
    echo "tips: file not found: $file" >&2
    return 1
  fi
  "${EDITOR:-vi}" "$file"
}

# ===== MAIN =====

tips() {
  case "${1:-}" in
    "")           _tips_cmd_random ;;
    list)         shift; _tips_cmd_list "$@" ;;
    count)        shift; _tips_cmd_count "$@" ;;
    refresh)      shift; _tips_cmd_refresh "$@" ;;
    status)       _tips_cmd_status ;;
    sources)      _tips_cmd_sources ;;
    edit)         shift; _tips_cmd_edit "$@" ;;
    version|-v|--version) printf "tips v%s\n" "$__TIPS_VERSION" ;;
    help|-h|--help) _tips_usage ;;
    *)            echo "tips: unknown command: $1" >&2; _tips_usage; return 1 ;;
  esac
}

_tips_init

# Allow direct execution (not only sourced)
# In bash: BASH_SOURCE[0] is set when sourced. In zsh: ZSH_EVAL_CONTEXT contains 'file' when sourced.
_tips_is_sourced() {
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    [[ "${BASH_SOURCE[0]}" != "$0" ]]
  elif [[ -n "${ZSH_EVAL_CONTEXT:-}" ]]; then
    [[ "$ZSH_EVAL_CONTEXT" == *:file:* || "$ZSH_EVAL_CONTEXT" == *:file ]]
  else
    return 1  # assume direct execution
  fi
}

if ! _tips_is_sourced; then
  tips "$@"
fi
