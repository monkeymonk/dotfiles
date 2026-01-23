#!/usr/bin/env bash
# Bootstrap for assistant toolchain (idempotent)
# - Always ensures global assistant home exists
# - Then (if project context is available) ensures project dirs exist
# - Exports normalized paths for other scripts

set -euo pipefail

# Detect whether we're sourced or executed
_assistant_is_sourced=0
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  _assistant_is_sourced=1
fi

_assistant_fail() {
  echo "assistant bootstrap error: $1" >&2
  if [[ $_assistant_is_sourced -eq 1 ]]; then
    return 1
  else
    exit 1
  fi
}

_assistant_info() {
  # keep it low-noise; comment out if you prefer silent bootstrap
  echo "assistant bootstrap: $1" >&2
}

# ---- global assistant home --------------------------------------------------

ASSISTANT_HOME="${ASSISTANT_HOME:-$HOME/.assistant}"
RAW_HISTORY="$ASSISTANT_HOME/raw_history.log"

if [[ ! -d "$ASSISTANT_HOME" ]]; then
  mkdir -p "$ASSISTANT_HOME" || _assistant_fail "cannot create $ASSISTANT_HOME"
  _assistant_info "created $ASSISTANT_HOME"
fi

if [[ ! -f "$RAW_HISTORY" ]]; then
  touch "$RAW_HISTORY" || _assistant_fail "cannot create $RAW_HISTORY"
  chmod 600 "$RAW_HISTORY" || true
  _assistant_info "created $RAW_HISTORY"
fi

export ASSISTANT_HOME
export RAW_HISTORY

# ---- project context (optional for some commands) ---------------------------

# If a script requires project context, it should set REQUIRE_PROJECT=1
REQUIRE_PROJECT="${REQUIRE_PROJECT:-1}"

# If project vars are missing and we don't require them, stop here successfully
if [[ -z "${PROJECT_ROOT:-}" || -z "${PROJECT_ID:-}" || -z "${ORG_ID:-}" ]]; then
  if [[ "$REQUIRE_PROJECT" -eq 1 ]]; then
    _assistant_fail "ORG_ID / PROJECT_ID / PROJECT_ROOT must be set"
  else
    # Global bootstrap only
    return 0 2>/dev/null || exit 0
  fi
fi

# Expand ~ and normalize PROJECT_ROOT
PROJECT_ROOT_EXPANDED="${PROJECT_ROOT/#\~/$HOME}"

if [[ ! -d "$PROJECT_ROOT_EXPANDED" ]]; then
  _assistant_fail "PROJECT_ROOT does not exist: $PROJECT_ROOT_EXPANDED"
fi

PROJECT_ROOT="$(cd "$PROJECT_ROOT_EXPANDED" && pwd)"
PROJECT_DIR="$PROJECT_ROOT/.project"
PROJECT_META="$PROJECT_DIR/project.yaml"
COMMANDS_LOG="$PROJECT_DIR/commands.log"

if [[ ! -d "$PROJECT_DIR" ]]; then
  mkdir -p "$PROJECT_DIR" || _assistant_fail "cannot create $PROJECT_DIR"
  _assistant_info "created $PROJECT_DIR"
fi

if [[ ! -f "$PROJECT_META" ]]; then
  cat >"$PROJECT_META" <<EOF
# Project metadata
org: $ORG_ID
id: $PROJECT_ID
risk: unknown
components: {}
EOF
  _assistant_info "created $PROJECT_META"
fi

if [[ ! -f "$COMMANDS_LOG" ]]; then
  cat >"$COMMANDS_LOG" <<EOF
# Project Commands – $PROJECT_ID

> This file is curated automatically and manually.
> Remove anything that stops being useful.

EOF
  _assistant_info "created $COMMANDS_LOG"
fi

export ORG_ID
export PROJECT_ID
export PROJECT_ROOT
export PROJECT_DIR
export PROJECT_META
export COMMANDS_LOG

# successful return/exit
return 0 2>/dev/null || exit 0
