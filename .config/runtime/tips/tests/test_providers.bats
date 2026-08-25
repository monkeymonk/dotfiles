#!/usr/bin/env bats
load '../tests/test_helper'

setup() { setup_tips; }

# --- static provider ---

@test "static provider is registered" {
  [[ " ${__TIPS_PROVIDERS[*]} " == *" static "* ]]
}

@test "static provider lists tips from TIPS_DATA_FILE" {
  run _tips_pcall static list
  assert_success
  assert_output --partial "tip one"
  assert_output --partial "tip two"
  assert_output --partial "tip three"
}

@test "static provider skips comment lines" {
  run _tips_pcall static list
  refute_output --partial "# test tips"
}

@test "static provider returns failure when file missing" {
  TIPS_DATA_FILE="/nonexistent/tips.txt"
  run _tips_pcall static list
  assert_failure
}

@test "static provider name is Static" {
  run _tips_pcall static name
  assert_output "Static"
}

@test "static provider weight is 30" {
  run _tips_pcall static weight
  assert_output "30"
}

@test "static provider generate returns failure (not supported)" {
  run _tips_pcall static generate
  assert_failure
}

@test "static provider edit_path returns TIPS_DATA_FILE" {
  run _tips_pcall static edit_path
  assert_output "$TIPS_DATA_FILE"
}

@test "static provider status shows file path" {
  run _tips_pcall static status
  assert_output --partial "file="
}

# --- custom provider ---

@test "custom provider with all methods works" {
  tips_provider_full_name() { echo "Full"; }
  tips_provider_full_weight() { echo 60; }
  tips_provider_full_list() { echo "full tip"; }
  tips_provider_full_status() { echo "ok=yes"; }
  tips_provider_full_generate() { return 0; }
  tips_register_provider full

  run _tips_pcall full name
  assert_output "Full"

  run _tips_pcall full weight
  assert_output "60"

  run _tips_pcall full list
  assert_output "full tip"

  run _tips_pcall full status
  assert_output "ok=yes"

  run _tips_pcall full generate
  assert_success
}

# --- url provider ---

@test "url provider is registered" {
  [[ " ${__TIPS_PROVIDERS[*]} " == *" url "* ]]
}

@test "url provider has weight 0 when no sources configured" {
  unset TIPS_URL_SOURCES TIPS_URL_WEIGHT
  run _tips_pcall url weight
  assert_output "0"
}

@test "url provider has weight 30 when sources configured" {
  TIPS_URL_SOURCES="https://example.com/tips.txt"
  unset TIPS_URL_WEIGHT
  run _tips_pcall url weight
  assert_output "30"
}

@test "url provider list returns failure when no sources" {
  unset TIPS_URL_SOURCES
  run _tips_pcall url list
  assert_failure
}

@test "url provider reads from cached file" {
  TIPS_URL_SOURCES="https://example.com/tips.txt"
  TIPS_CACHE_DIR="$BATS_TMPDIR/tips-cache-$$"
  local cache_file
  cache_file=$(_tips_url_cache_file "https://example.com/tips.txt")
  mkdir -p "$(dirname "$cache_file")"
  cat > "$cache_file" <<'EOF'
# header
url tip one
url tip two
EOF
  # backdate so it's still fresh under default TTL
  run _tips_pcall url list
  assert_success
  assert_output --partial "url tip one"
  assert_output --partial "url tip two"
  refute_output --partial "# header"
}

@test "url provider status reports unconfigured state" {
  unset TIPS_URL_SOURCES
  run _tips_pcall url status
  assert_output --partial "sources=0"
}

# --- llm provider ---

@test "llm provider is registered" {
  [[ " ${__TIPS_PROVIDERS[*]} " == *" llm "* ]]
}

@test "llm provider weight is 0 when backend is none" {
  TIPS_LLM_BACKEND=none
  unset TIPS_LLM_WEIGHT
  TIPS_CACHE_DIR="$BATS_TMPDIR/tips-cache-llm-$$"
  run _tips_pcall llm weight
  assert_output "0"
}

@test "llm provider weight respects TIPS_LLM_WEIGHT override" {
  TIPS_LLM_WEIGHT=42
  run _tips_pcall llm weight
  assert_output "42"
}

@test "llm provider list returns failure when no cache" {
  TIPS_CACHE_DIR="$BATS_TMPDIR/tips-cache-llm-empty-$$"
  run _tips_pcall llm list
  assert_failure
}

@test "llm provider generate fails cleanly when backend is none" {
  TIPS_LLM_BACKEND=none
  TIPS_CACHE_DIR="$BATS_TMPDIR/tips-cache-llm-gen-$$"
  run _tips_pcall llm generate
  assert_failure
  assert_output --partial "no backend"
}

# --- random selection ---

@test "provider with weight 0 is excluded from random" {
  tips_provider_zero_name() { echo "Zero"; }
  tips_provider_zero_weight() { echo 0; }
  tips_provider_zero_list() { echo "should not appear"; }
  tips_register_provider zero

  # Run random 10 times — should never get "should not appear"
  local i
  for i in $(seq 1 10); do
    run tips
    refute_output "should not appear"
  done
}
