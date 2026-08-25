#!/usr/bin/env bash
# tips provider: llm — project-aware tips via a chat-completion backend.
#
# Backends (set TIPS_LLM_BACKEND, default "auto"):
#   auto       — probe local llama.cpp (:8080), Ollama (:11434), then env keys.
#                Result is cached in $TIPS_CACHE_DIR/llm/backend.
#   openai     — OpenAI-compatible /v1/chat/completions endpoint.
#                Covers OpenAI, OpenRouter, Groq, Together, llama.cpp's
#                llama-server, Ollama, vLLM, LM Studio — anything that speaks
#                the OpenAI wire format.
#   anthropic  — native Anthropic /v1/messages endpoint.
#   custom     — external generator command. Takes a directory as $1, prints
#                tips to stdout (one per line). Set TIPS_LLM_GENERATOR.
#   none       — disable provider.
#
# Configuration (set in $TIPS_CONFIG_DIR/config.sh):
#   TIPS_LLM_BACKEND     — auto | openai | anthropic | custom | none (default: auto)
#   TIPS_LLM_URL         — base URL for openai backend (default per backend)
#   TIPS_LLM_MODEL       — model name (defaults: gpt-4o-mini, claude-haiku-4-5)
#   TIPS_LLM_API_KEY     — API key for openai backend; falls back to OPENAI_API_KEY
#   TIPS_LLM_GENERATOR   — command name for custom backend (default: tips-generate)
#   TIPS_LLM_TTL         — cache TTL in seconds (default: 3600)
#   TIPS_LLM_TIMEOUT     — request timeout in seconds (default: 60)
#   TIPS_LLM_WEIGHT      — selection weight (default: 70 when backend ready, 0 otherwise)
#
# Cache layout:
#   $TIPS_CACHE_DIR/llm/backend       — auto-detected backend name
#   $TIPS_CACHE_DIR/llm/<hash>        — per-directory generated tips

: "${TIPS_LLM_BACKEND:=auto}"
: "${TIPS_LLM_TTL:=3600}"
: "${TIPS_LLM_TIMEOUT:=60}"
: "${TIPS_LLM_GENERATOR:=tips-generate}"

tips_provider_llm_name() { echo "LLM"; }

# ---- helpers ----

_tips_llm_hash() {
  local input="$1"
  if command -v md5sum &>/dev/null; then
    printf '%s' "$input" | md5sum | cut -d' ' -f1
  elif command -v md5 &>/dev/null; then
    printf '%s' "$input" | md5 -q
  else
    printf '%s' "$input" | tr -c '[:alnum:]_-' '_'
  fi
}

_tips_llm_cache_file() {
  local dir="${1:-$PWD}"
  echo "$TIPS_CACHE_DIR/llm/$(_tips_llm_hash "tips:$dir")"
}

_tips_llm_backend_cache() { echo "$TIPS_CACHE_DIR/llm/backend"; }

_tips_llm_probe_url() {
  # Returns 0 if a TCP service answers on host:port within 1s.
  local host="$1" port="$2"
  if command -v curl &>/dev/null; then
    curl -fsS --max-time 1 -o /dev/null "http://$host:$port/" 2>/dev/null
    # 0 on 2xx, non-zero on connect failure or non-2xx; we only care about reachability.
    # Treat connect failures (exit 7) as "no service"; other failures as "service present".
    local rc=$?
    [[ $rc -eq 7 ]] && return 1
    return 0
  fi
  return 1
}

_tips_llm_detect_backend() {
  # Returns the resolved backend name on stdout. Empty if none.
  if [[ "$TIPS_LLM_BACKEND" != "auto" ]]; then
    echo "$TIPS_LLM_BACKEND"
    return
  fi
  local cache; cache=$(_tips_llm_backend_cache)
  if [[ -r "$cache" ]]; then
    cat "$cache"
    return
  fi
  local resolved=""
  if _tips_llm_probe_url 127.0.0.1 8080; then
    resolved="openai"
    : "${TIPS_LLM_URL:=http://127.0.0.1:8080}"
    : "${TIPS_LLM_MODEL:=local}"
  elif _tips_llm_probe_url 127.0.0.1 11434; then
    resolved="openai"
    : "${TIPS_LLM_URL:=http://127.0.0.1:11434}"
    : "${TIPS_LLM_MODEL:=llama3.2}"
  elif [[ -n "${OPENAI_API_KEY:-}" ]]; then
    resolved="openai"
    : "${TIPS_LLM_URL:=https://api.openai.com}"
    : "${TIPS_LLM_MODEL:=gpt-4o-mini}"
  elif [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
    resolved="anthropic"
    : "${TIPS_LLM_MODEL:=claude-haiku-4-5}"
  elif command -v "$TIPS_LLM_GENERATOR" &>/dev/null; then
    resolved="custom"
  else
    resolved="none"
  fi
  mkdir -p "$(dirname "$cache")"
  printf '%s\n' "$resolved" > "$cache"
  echo "$resolved"
}

_tips_llm_apply_defaults() {
  # Set per-backend defaults if not already set. Called by both detect and direct backends.
  case "$1" in
    openai)
      : "${TIPS_LLM_URL:=https://api.openai.com}"
      : "${TIPS_LLM_MODEL:=gpt-4o-mini}"
      : "${TIPS_LLM_API_KEY:=${OPENAI_API_KEY:-}}"
      ;;
    anthropic)
      : "${TIPS_LLM_MODEL:=claude-haiku-4-5}"
      : "${TIPS_LLM_API_KEY:=${ANTHROPIC_API_KEY:-}}"
      ;;
  esac
  export TIPS_LLM_URL TIPS_LLM_MODEL TIPS_LLM_API_KEY
}

_tips_llm_prompt() {
  local dir="$1"
  cat <<EOF
You are a terminal tip generator for power users. Output ONLY plain tip lines.
STRICT RULES:
- One tip per line
- No numbering, bullets, prefixes, or markdown
- No blank lines, no preamble, no closing remarks
- Each tip under 100 characters
- 8-12 tips total
- Tips must be specific to the project at: $dir
- Reference actual files, tools, and commands visible in that directory
EOF
}

_tips_llm_context() {
  # Compact directory snapshot — names, key files, languages — without dumping content.
  local dir="$1" max=40
  echo "Directory: $dir"
  echo
  echo "Top-level entries:"
  ls -A "$dir" 2>/dev/null | head -n "$max"
  echo
  for f in README.md README.rst README.txt package.json pyproject.toml Cargo.toml go.mod Makefile justfile; do
    if [[ -f "$dir/$f" ]]; then
      echo "--- $f (first 30 lines) ---"
      head -n 30 "$dir/$f" 2>/dev/null
      echo
    fi
  done
}

_tips_llm_clean() {
  # Strip numbering, bullets, leading/trailing whitespace, and blank lines.
  sed 's/^[[:space:]]*[0-9]\{1,2\}[.)]\{1,2\}[[:space:]]*//' \
    | sed 's/^[[:space:]]*[-*•][[:space:]]*//' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
    | grep -v '^$'
}

# ---- backends ----

_tips_llm_call_openai() {
  local dir="$1" prompt context payload
  command -v curl &>/dev/null || { echo "llm: curl required" >&2; return 1; }
  command -v jq &>/dev/null || { echo "llm: jq required for openai backend" >&2; return 1; }
  prompt=$(_tips_llm_prompt "$dir")
  context=$(_tips_llm_context "$dir")
  payload=$(jq -n \
    --arg model "$TIPS_LLM_MODEL" \
    --arg sys "$prompt" \
    --arg ctx "$context" \
    '{model: $model, messages: [{role:"system", content:$sys}, {role:"user", content:$ctx}], temperature: 0.7}')
  local hdr=(-H "Content-Type: application/json")
  [[ -n "${TIPS_LLM_API_KEY:-}" ]] && hdr+=(-H "Authorization: Bearer $TIPS_LLM_API_KEY")
  local resp
  resp=$(curl -fsS --max-time "$TIPS_LLM_TIMEOUT" "${hdr[@]}" \
    -d "$payload" "$TIPS_LLM_URL/v1/chat/completions" 2>/dev/null) || return 1
  printf '%s' "$resp" | jq -r '.choices[0].message.content // empty' | _tips_llm_clean
}

_tips_llm_call_anthropic() {
  local dir="$1" prompt context payload
  command -v curl &>/dev/null || { echo "llm: curl required" >&2; return 1; }
  command -v jq &>/dev/null || { echo "llm: jq required for anthropic backend" >&2; return 1; }
  [[ -n "${TIPS_LLM_API_KEY:-}" ]] || { echo "llm: ANTHROPIC_API_KEY not set" >&2; return 1; }
  prompt=$(_tips_llm_prompt "$dir")
  context=$(_tips_llm_context "$dir")
  payload=$(jq -n \
    --arg model "$TIPS_LLM_MODEL" \
    --arg sys "$prompt" \
    --arg ctx "$context" \
    '{model: $model, max_tokens: 1024, system: $sys, messages: [{role:"user", content:$ctx}]}')
  local resp
  resp=$(curl -fsS --max-time "$TIPS_LLM_TIMEOUT" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $TIPS_LLM_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d "$payload" "https://api.anthropic.com/v1/messages" 2>/dev/null) || return 1
  printf '%s' "$resp" | jq -r '.content[0].text // empty' | _tips_llm_clean
}

_tips_llm_call_custom() {
  local dir="$1"
  command -v "$TIPS_LLM_GENERATOR" &>/dev/null || {
    echo "llm: generator not found: $TIPS_LLM_GENERATOR" >&2
    return 1
  }
  "$TIPS_LLM_GENERATOR" "$dir"
}

# ---- provider interface ----

tips_provider_llm_weight() {
  if [[ -n "${TIPS_LLM_WEIGHT:-}" ]]; then
    echo "$TIPS_LLM_WEIGHT"
    return
  fi
  local backend
  backend=$(_tips_llm_detect_backend)
  if [[ -z "$backend" || "$backend" == "none" ]]; then
    echo 0
  else
    echo 70
  fi
}

tips_provider_llm_list() {
  local cache_file
  cache_file=$(_tips_llm_cache_file "$PWD")
  [[ -r "$cache_file" ]] || return 1
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    echo "$line"
  done < "$cache_file"
}

tips_provider_llm_generate() {
  local dir="${1:-$PWD}"
  dir="$(cd "$dir" 2>/dev/null && pwd)" || return 1

  local backend
  backend=$(_tips_llm_detect_backend)
  [[ -z "$backend" || "$backend" == "none" ]] && {
    echo "llm: no backend available (set TIPS_LLM_BACKEND or provide an API key)" >&2
    return 1
  }
  _tips_llm_apply_defaults "$backend"

  local cache_file
  cache_file=$(_tips_llm_cache_file "$dir")
  mkdir -p "$(dirname "$cache_file")"

  echo "Generating tips for $dir via $backend ..."
  local start output elapsed count
  start=$SECONDS
  case "$backend" in
    openai)    output=$(_tips_llm_call_openai "$dir") ;;
    anthropic) output=$(_tips_llm_call_anthropic "$dir") ;;
    custom)    output=$(_tips_llm_call_custom "$dir") ;;
    *)         echo "llm: unknown backend: $backend" >&2; return 1 ;;
  esac
  elapsed=$(( SECONDS - start ))

  if [[ -z "$output" ]]; then
    echo "llm: backend returned empty output" >&2
    return 1
  fi

  printf '%s\n' "$output" > "$cache_file"
  count=$(printf '%s\n' "$output" | wc -l | tr -d ' ')
  echo "Done — $count tips cached in ${elapsed}s"
}

tips_provider_llm_status() {
  local backend cache_file mtime age now
  backend=$(_tips_llm_detect_backend)
  echo "backend=${backend:-none}"
  case "$backend" in
    openai)
      _tips_llm_apply_defaults openai
      echo "url=$TIPS_LLM_URL"
      echo "model=$TIPS_LLM_MODEL"
      [[ -n "$TIPS_LLM_API_KEY" ]] && echo "api_key=set" || echo "api_key=unset"
      ;;
    anthropic)
      _tips_llm_apply_defaults anthropic
      echo "model=$TIPS_LLM_MODEL"
      [[ -n "$TIPS_LLM_API_KEY" ]] && echo "api_key=set" || echo "api_key=unset"
      ;;
    custom)
      echo "generator=$TIPS_LLM_GENERATOR"
      ;;
  esac
  echo "ttl=${TIPS_LLM_TTL}s"
  cache_file=$(_tips_llm_cache_file "$PWD")
  echo "cache=$cache_file"
  if [[ -r "$cache_file" ]]; then
    echo "cached=yes"
    mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)
    if [[ -n "$mtime" ]]; then
      now=$(date +%s)
      age=$(( now - mtime ))
      echo "age=${age}s"
      (( age > TIPS_LLM_TTL )) && echo "stale=yes" || echo "stale=no"
    fi
  else
    echo "cached=no"
  fi
}

tips_provider_llm_edit_path() {
  echo "$(_tips_llm_cache_file "$PWD")"
}

tips_register_provider llm
