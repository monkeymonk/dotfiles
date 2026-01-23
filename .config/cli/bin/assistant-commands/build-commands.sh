#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Bootstrap (ensures paths, env vars, files exist)
# ---------------------------------------------------------------------------

source "$(dirname "$0")/bootstrap.sh"

MODEL="${OLLAMA_MODEL:-qwen2.5:7b}"

# How much raw history to consider per run
HISTORY_LINES="${ASSISTANT_HISTORY_LINES:-2000}"

# ---------------------------------------------------------------------------
# Inputs
# ---------------------------------------------------------------------------

CURATED_COMMANDS_FILE="$COMMANDS_LOG"
PROJECT_META_FILE="$PROJECT_META"

RAW_HISTORY="$(history | tail -n "$HISTORY_LINES")"

EXISTING_COMMANDS=""
if [[ -s "$CURATED_COMMANDS_FILE" ]]; then
  EXISTING_COMMANDS="$(sed 's/^/  /' "$CURATED_COMMANDS_FILE")"
fi

PROJECT_META=""
if [[ -f "$PROJECT_META_FILE" ]]; then
  PROJECT_META="$(sed 's/^/  /' "$PROJECT_META_FILE")"
fi

# ---------------------------------------------------------------------------
# Prompt
# ---------------------------------------------------------------------------

echo "assistant build-commands: started"

PROMPT=$(
  cat <<EOF
You are curating a reusable command reference for a software project.

Project identity:
- Organization: $ORG_ID
- Project: $PROJECT_ID
- Project root path: $PROJECT_ROOT

Project structure (if provided):
$PROJECT_META

Existing curated commands (keep these unless clearly wrong):
$EXISTING_COMMANDS

New input:
A raw shell command history that may include commands from many unrelated projects.

Your task:
1. Identify commands that clearly relate to THIS project.
   Use clues such as:
   - Paths under the project root
   - Project-specific domains, services, repo names
   - Stack-specific tools (npm, pnpm, composer, artisan, docker, etc.)
2. Merge relevant commands with the existing curated list.
3. Do NOT duplicate commands already present.
4. Normalize commands so they are reusable.
5. Group commands by purpose.

Rules:
- Ignore trivial shell navigation (cd, ls, pwd, clear, exit).
- Ignore generic commands with no project specificity.
- Prefer clarity over completeness.
- Do NOT invent commands.

Output format:
- Markdown only
- Short section headers (Setup, Dev, Test, Debug, Maintenance, etc.)
- Bullet lists of commands
- No explanations
- No commentary

Shell command history:
$RAW_HISTORY
EOF
)

# ---------------------------------------------------------------------------
# Run Ollama
# ---------------------------------------------------------------------------

echo "assistant: building commands.log for $PROJECT_ID"

SUMMARY="$(ollama run "$MODEL" <<<"$PROMPT")"

# ---------------------------------------------------------------------------
# Write result (overwrite intentionally)
# ---------------------------------------------------------------------------

cat >"$CURATED_COMMANDS_FILE" <<EOF
# Project Commands – $PROJECT_ID
# Updated on $(date -Iseconds)

> This file is curated automatically and manually.
> Remove anything that stops being useful.

$SUMMARY
EOF

echo "assistant: commands.log updated"
