#!/usr/bin/env bash
# tips installer — fetches tips.sh, providers, and a default tips.txt
# into the user's config directory and patches their shell rc.
#
# Usage:
#   curl -fsSL https://.../install.sh | bash
#   curl -fsSL https://.../install.sh | bash -s -- --uninstall
#   ./install.sh --local                # install from this checkout (no network)
#
# Environment overrides:
#   TIPS_REPO_OWNER   — GitHub org/user (default: monkeymonk)
#   TIPS_REPO_NAME    — GitHub repo name (default: tips)
#   TIPS_VERSION      — tag or branch to install (default: latest tag, falls back to main)
#   TIPS_BIN_DIR      — install location for tips.sh (default: ~/.local/bin)
#   TIPS_CONFIG_DIR   — config root (default: $XDG_CONFIG_HOME/tips or ~/.config/tips)
#   TIPS_DATA_DIR     — data dir (default: $XDG_DATA_HOME/tips or $TIPS_CONFIG_DIR/data)
#   TIPS_NO_RC_PATCH  — set to skip shell rc patching

set -euo pipefail

TIPS_REPO_OWNER="${TIPS_REPO_OWNER:-monkeymonk}"
TIPS_REPO_NAME="${TIPS_REPO_NAME:-tips}"
TIPS_BIN_DIR="${TIPS_BIN_DIR:-$HOME/.local/bin}"
TIPS_CONFIG_DIR="${TIPS_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/tips}"
if [[ -n "${XDG_DATA_HOME:-}" ]]; then
  TIPS_DATA_DIR="${TIPS_DATA_DIR:-$XDG_DATA_HOME/tips}"
else
  TIPS_DATA_DIR="${TIPS_DATA_DIR:-$TIPS_CONFIG_DIR/data}"
fi

MODE="install"
LOCAL_SRC=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall) MODE="uninstall"; shift ;;
    --local)     LOCAL_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; shift ;;
    --version)   TIPS_VERSION="${2:-}"; shift 2 ;;
    -h|--help)
      sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *) echo "tips install: unknown arg: $1" >&2; exit 2 ;;
  esac
done

# ===== helpers =====

_have() { command -v "$1" >/dev/null 2>&1; }

_detect_shell_rc() {
  if [[ -n "${ZSH_VERSION:-}" ]] || [[ "${SHELL:-}" == */zsh ]]; then
    echo "$HOME/.zshrc"
  else
    echo "$HOME/.bashrc"
  fi
}

_confirm() {
  local prompt="$1" reply
  if [[ ! -t 0 ]]; then
    # Non-interactive (curl | bash): assume yes for rc patch unless suppressed
    [[ -n "${TIPS_NO_RC_PATCH:-}" ]] && return 1
    return 0
  fi
  printf '%s [y/N] ' "$prompt" >&2
  read -r reply </dev/tty
  [[ "$reply" =~ ^[Yy]$ ]]
}

_download() {
  local url="$1" dest="$2"
  if [[ "$url" == https://raw.githubusercontent.com/* ]] && [[ "$url" != *\?* ]]; then
    url="${url}?ts=$(date +%s)"
  fi
  if _have curl; then
    curl -fsSL "$url" -o "$dest"
  elif _have wget; then
    wget -qO "$dest" "$url"
  else
    echo "tips install: curl or wget required" >&2
    exit 1
  fi
}

_latest_tag() {
  local api="https://api.github.com/repos/$TIPS_REPO_OWNER/$TIPS_REPO_NAME/tags?per_page=1"
  local raw
  if _have curl; then raw="$(curl -fsSL "$api" 2>/dev/null || true)"
  elif _have wget; then raw="$(wget -qO - "$api" 2>/dev/null || true)"
  else return 1
  fi
  if _have jq; then
    printf '%s' "$raw" | jq -r '.[0].name // empty' 2>/dev/null
  else
    printf '%s' "$raw" | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]\+\)".*/\1/p' | head -n1
  fi
}

# Discover providers from a remote tag (best-effort) or local checkout.
_list_remote_providers() {
  local base="$1"
  local api="https://api.github.com/repos/$TIPS_REPO_OWNER/$TIPS_REPO_NAME/contents/providers?ref=${TIPS_VERSION:-main}"
  local raw
  if _have curl; then raw="$(curl -fsSL "$api" 2>/dev/null || true)"
  elif _have wget; then raw="$(wget -qO - "$api" 2>/dev/null || true)"
  fi
  if [[ -z "$raw" ]]; then
    # Fallback to a known list
    printf '%s\n' static url llm
    return
  fi
  if _have jq; then
    printf '%s' "$raw" | jq -r '.[] | select(.name | endswith(".sh")) | .name | sub("\\.sh$"; "")'
  else
    printf '%s' "$raw" | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]\+\)\.sh".*/\1/p'
  fi
}

_patch_rc() {
  local rc="$1"
  local new_line="source \"$TIPS_BIN_DIR/tips.sh\""
  if grep -qF "$new_line" "$rc" 2>/dev/null; then
    echo "tips: already sourced in $rc"
    return
  fi
  if _confirm "tips: append source line to $rc?"; then
    printf '\n# tips — extensible tip aggregator\n%s\n' "$new_line" >> "$rc"
    echo "tips: added source line to $rc"
  else
    echo "tips: skipped $rc — add manually: $new_line"
  fi
}

_unpatch_rc() {
  local rc="$1"
  [[ -f "$rc" ]] || return 0
  if grep -qF "tips.sh" "$rc"; then
    local tmp; tmp="$(mktemp)"
    awk '
      /^# tips — extensible tip aggregator$/ { skip=1; next }
      skip && /tips\.sh/ { skip=0; next }
      { print }
    ' "$rc" > "$tmp"
    mv "$tmp" "$rc"
    echo "tips: removed source line from $rc"
  fi
}

_seed_config() {
  local cfg="$TIPS_CONFIG_DIR/config.sh"
  [[ -f "$cfg" ]] && { echo "tips: $cfg already exists, skipping"; return; }
  cat > "$cfg" <<'CONFIG'
# tips config — sourced before providers load.
# All settings are optional; defaults work out of the box.

# --- paths ---
# TIPS_DATA_DIR="$HOME/.local/share/tips"
# TIPS_DATA_FILE="$TIPS_DATA_DIR/tips.txt"
# TIPS_CACHE_DIR="$HOME/.cache/tips"

# --- static provider ---
# (no settings — edit $TIPS_DATA_FILE directly, or run `tips edit`)

# --- url provider ---
# Multiple sources supported (whitespace- or newline-separated).
# Each URL must serve plain text, one tip per line.
# TIPS_URL_SOURCES="https://example.com/tips.txt"
# TIPS_URL_TTL=86400        # cache age in seconds (default 1 day)
# TIPS_URL_WEIGHT=30        # selection weight (auto: 0 unset, 30 when set)

# --- llm provider ---
# Backend: auto | openai | anthropic | custom | none
# "auto" probes local llama.cpp (:11435), Ollama (:11434), then $OPENAI_API_KEY,
# then $ANTHROPIC_API_KEY, and caches the result in $TIPS_CACHE_DIR/llm/backend.
# TIPS_LLM_BACKEND=auto
#
# OpenAI-compatible (also covers OpenRouter, Groq, Together, llama.cpp, Ollama, etc.)
# TIPS_LLM_URL=http://127.0.0.1:11435
# TIPS_LLM_MODEL=gpt-4o-mini
# TIPS_LLM_API_KEY="$OPENAI_API_KEY"
#
# Anthropic native API
# TIPS_LLM_MODEL=claude-haiku-4-5
# TIPS_LLM_API_KEY="$ANTHROPIC_API_KEY"
#
# Custom external generator (takes dir as $1, prints tips to stdout)
# TIPS_LLM_GENERATOR=tips-generate
#
# TIPS_LLM_TTL=3600
# TIPS_LLM_TIMEOUT=60
# TIPS_LLM_WEIGHT=70
CONFIG
  echo "tips: created $cfg"
}

# ===== uninstall =====

if [[ "$MODE" == "uninstall" ]]; then
  echo "Uninstalling tips..."
  rm -f "$TIPS_BIN_DIR/tips.sh" && echo "tips: removed $TIPS_BIN_DIR/tips.sh" || true
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do _unpatch_rc "$rc"; done
  if _confirm "tips: also delete $TIPS_CONFIG_DIR (config + caches)?"; then
    rm -rf "$TIPS_CONFIG_DIR"
    echo "tips: removed $TIPS_CONFIG_DIR"
  else
    echo "tips: kept $TIPS_CONFIG_DIR"
  fi
  echo "Done."
  exit 0
fi

# ===== install =====

echo "Installing tips..."
mkdir -p "$TIPS_BIN_DIR" "$TIPS_CONFIG_DIR/providers" "$TIPS_CONFIG_DIR/integrations" "$TIPS_DATA_DIR"

if [[ -n "$LOCAL_SRC" ]]; then
  echo "tips: installing from local source: $LOCAL_SRC"
  cp "$LOCAL_SRC/tips.sh" "$TIPS_BIN_DIR/tips.sh"
  for f in "$LOCAL_SRC/providers"/*.sh; do
    [[ -f "$f" ]] || continue
    cp "$f" "$TIPS_CONFIG_DIR/providers/$(basename "$f")"
  done
  if [[ -d "$LOCAL_SRC/integrations" ]]; then
    for f in "$LOCAL_SRC/integrations"/*; do
      [[ -f "$f" ]] || continue
      cp "$f" "$TIPS_CONFIG_DIR/integrations/$(basename "$f")"
    done
  fi
  if [[ -f "$LOCAL_SRC/data/tips.txt" && ! -f "$TIPS_DATA_DIR/tips.txt" ]]; then
    cp "$LOCAL_SRC/data/tips.txt" "$TIPS_DATA_DIR/tips.txt"
    echo "tips: seeded $TIPS_DATA_DIR/tips.txt"
  fi
else
  if [[ -z "${TIPS_VERSION:-}" ]]; then
    TIPS_VERSION="$(_latest_tag || true)"
    if [[ -z "$TIPS_VERSION" ]]; then
      echo "tips: could not determine latest tag, using main"
      TIPS_VERSION="main"
    else
      echo "tips: using version $TIPS_VERSION"
    fi
  fi
  TIPS_BASE="https://raw.githubusercontent.com/$TIPS_REPO_OWNER/$TIPS_REPO_NAME/$TIPS_VERSION"

  _download "$TIPS_BASE/tips.sh" "$TIPS_BIN_DIR/tips.sh"

  for provider in $(_list_remote_providers "$TIPS_BASE"); do
    _download "$TIPS_BASE/providers/${provider}.sh" "$TIPS_CONFIG_DIR/providers/${provider}.sh"
  done

  # Best-effort integrations fetch (skipped if not present at this ref)
  for integ in zsh-idle.zsh; do
    _download "$TIPS_BASE/integrations/${integ}" "$TIPS_CONFIG_DIR/integrations/${integ}" 2>/dev/null || true
  done

  if [[ ! -f "$TIPS_DATA_DIR/tips.txt" ]]; then
    _download "$TIPS_BASE/data/tips.txt" "$TIPS_DATA_DIR/tips.txt"
    echo "tips: seeded $TIPS_DATA_DIR/tips.txt"
  fi
fi

chmod +x "$TIPS_BIN_DIR/tips.sh" 2>/dev/null || true
_seed_config

if [[ -z "${TIPS_NO_RC_PATCH:-}" ]]; then
  _patch_rc "$(_detect_shell_rc)"
else
  echo "tips: skipped rc patch (TIPS_NO_RC_PATCH set)"
fi

echo
echo "tips installed to $TIPS_BIN_DIR/tips.sh"
echo "Config: $TIPS_CONFIG_DIR"
echo "Data:   $TIPS_DATA_DIR"
echo
echo "Restart your shell, or: source $(_detect_shell_rc)"
echo "Then run: tips"
