#!/usr/bin/env bash
# tips provider: url — fetch tips from one or more HTTP(S) sources.
#
# Format expected at each URL: plain text, one tip per line.
# Lines starting with # and blank lines are ignored.
#
# Configuration (set in $TIPS_CONFIG_DIR/config.sh):
#   TIPS_URL_SOURCES   — newline- or whitespace-separated list of URLs.
#                        Disabled when empty (default).
#   TIPS_URL_TTL       — cache age in seconds (default 86400 = 1 day).
#   TIPS_URL_TIMEOUT   — per-request fetch timeout in seconds (default 5).
#   TIPS_URL_WEIGHT    — selection weight (default 30 when sources are set, 0 otherwise).

: "${TIPS_URL_SOURCES:=}"
: "${TIPS_URL_TTL:=86400}"
: "${TIPS_URL_TIMEOUT:=5}"

tips_provider_url_name() { echo "URL"; }

tips_provider_url_weight() {
  if [[ -n "${TIPS_URL_WEIGHT:-}" ]]; then
    echo "$TIPS_URL_WEIGHT"
  elif [[ -n "$TIPS_URL_SOURCES" ]]; then
    echo 30
  else
    echo 0
  fi
}

_tips_url_fetcher() {
  if command -v curl &>/dev/null; then
    echo "curl"
  elif command -v wget &>/dev/null; then
    echo "wget"
  else
    return 1
  fi
}

_tips_url_hash() {
  local input="$1"
  if command -v md5sum &>/dev/null; then
    printf '%s' "$input" | md5sum | cut -d' ' -f1
  elif command -v md5 &>/dev/null; then
    printf '%s' "$input" | md5 -q
  else
    printf '%s' "$input" | tr -c '[:alnum:]_-' '_'
  fi
}

_tips_url_cache_file() {
  local url="$1"
  echo "$TIPS_CACHE_DIR/url/$(_tips_url_hash "$url")"
}

_tips_url_iter_sources() {
  # Split TIPS_URL_SOURCES on whitespace/newlines; emit one URL per line.
  local src
  for src in $TIPS_URL_SOURCES; do
    [[ -n "$src" ]] && echo "$src"
  done
}

_tips_url_fetch_one() {
  local url="$1" cache_file="$2" fetcher
  fetcher=$(_tips_url_fetcher) || return 1
  mkdir -p "$(dirname "$cache_file")"
  local tmp="$cache_file.tmp.$$"
  if [[ "$fetcher" == "curl" ]]; then
    curl -fsSL --max-time "$TIPS_URL_TIMEOUT" "$url" -o "$tmp" 2>/dev/null || { rm -f "$tmp"; return 1; }
  else
    wget -q --timeout="$TIPS_URL_TIMEOUT" -O "$tmp" "$url" 2>/dev/null || { rm -f "$tmp"; return 1; }
  fi
  mv -f "$tmp" "$cache_file"
}

_tips_url_cache_fresh() {
  local cache_file="$1" mtime now age
  [[ -r "$cache_file" ]] || return 1
  mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)
  [[ -n "$mtime" ]] || return 1
  now=$(date +%s)
  age=$(( now - mtime ))
  (( age < TIPS_URL_TTL ))
}

tips_provider_url_list() {
  [[ -n "$TIPS_URL_SOURCES" ]] || return 1
  local url cache_file
  while IFS= read -r url; do
    cache_file=$(_tips_url_cache_file "$url")
    if ! _tips_url_cache_fresh "$cache_file"; then
      _tips_url_fetch_one "$url" "$cache_file" || {
        # Stale cache is better than nothing
        [[ -r "$cache_file" ]] || continue
      }
    fi
    while IFS= read -r line; do
      [[ -z "$line" || "$line" == \#* ]] && continue
      echo "$line"
    done < "$cache_file"
  done < <(_tips_url_iter_sources)
}

tips_provider_url_generate() {
  [[ -n "$TIPS_URL_SOURCES" ]] || { echo "url: no sources configured (set TIPS_URL_SOURCES)" >&2; return 1; }
  _tips_url_fetcher >/dev/null || { echo "url: curl or wget required" >&2; return 1; }
  local url cache_file ok=0 fail=0
  while IFS= read -r url; do
    cache_file=$(_tips_url_cache_file "$url")
    if _tips_url_fetch_one "$url" "$cache_file"; then
      ok=$(( ok + 1 ))
    else
      fail=$(( fail + 1 ))
      echo "url: failed to fetch $url" >&2
    fi
  done < <(_tips_url_iter_sources)
  echo "url: refreshed $ok, failed $fail"
  (( fail == 0 ))
}

tips_provider_url_status() {
  local url cache_file count=0 fresh=0 stale=0
  if [[ -z "$TIPS_URL_SOURCES" ]]; then
    echo "sources=0 (TIPS_URL_SOURCES not set)"
    return
  fi
  while IFS= read -r url; do
    count=$(( count + 1 ))
    cache_file=$(_tips_url_cache_file "$url")
    if _tips_url_cache_fresh "$cache_file"; then
      fresh=$(( fresh + 1 ))
    else
      [[ -r "$cache_file" ]] && stale=$(( stale + 1 ))
    fi
  done < <(_tips_url_iter_sources)
  echo "sources=$count fresh=$fresh stale=$stale ttl=${TIPS_URL_TTL}s"
  echo "cache=$TIPS_CACHE_DIR/url/"
}

tips_register_provider url
