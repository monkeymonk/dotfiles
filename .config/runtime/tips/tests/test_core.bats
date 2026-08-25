#!/usr/bin/env bats
load '../tests/test_helper'

setup() { setup_tips; }

@test "tips_register_provider adds provider to __TIPS_PROVIDERS" {
  tips_register_provider testprov
  [[ " ${__TIPS_PROVIDERS[*]} " == *" testprov "* ]]
}

@test "tips_register_provider deduplicates: calling twice registers once" {
  tips_register_provider deduptest
  tips_register_provider deduptest
  local count=0 p
  for p in "${__TIPS_PROVIDERS[@]}"; do
    [[ "$p" == "deduptest" ]] && count=$(( count + 1 ))
  done
  [ "$count" -eq 1 ]
}

@test "_tips_pcall dispatches to provider method" {
  tips_provider_testfn_name() { echo "TestFn"; }
  tips_register_provider testfn
  run _tips_pcall testfn name
  assert_output "TestFn"
}

@test "_tips_pcall returns 1 for missing method" {
  tips_register_provider nomethod
  run _tips_pcall nomethod nonexistent
  assert_failure
}

@test "_tips_pweight returns provider weight" {
  tips_provider_weighted_weight() { echo 80; }
  tips_register_provider weighted
  run _tips_pweight weighted
  assert_output "80"
}

@test "_tips_pweight defaults to 50 when method missing" {
  tips_register_provider noweight
  run _tips_pweight noweight
  assert_output "50"
}

@test "_tips_pname returns provider display name" {
  tips_provider_named_name() { echo "Named Provider"; }
  tips_register_provider named
  run _tips_pname named
  assert_output "Named Provider"
}

@test "_tips_pname falls back to provider key when method missing" {
  tips_register_provider fallbackname
  run _tips_pname fallbackname
  assert_output "fallbackname"
}

@test "_tips_init loads built-in providers" {
  _tips_init
  [[ " ${__TIPS_PROVIDERS[*]} " == *" static "* ]]
}

@test "_tips_init loads user providers from TIPS_CONFIG_DIR" {
  cat > "$TIPS_CONFIG_DIR/providers/custom.sh" <<'EOF'
tips_provider_custom_name() { echo "Custom"; }
tips_provider_custom_list() { echo "custom tip"; }
tips_register_provider custom
EOF
  _tips_init
  [[ " ${__TIPS_PROVIDERS[*]} " == *" custom "* ]]
}

@test "_tips_init resets providers on reload" {
  tips_register_provider ephemeral
  _tips_init
  [[ " ${__TIPS_PROVIDERS[*]} " != *" ephemeral "* ]]
}

@test "tips with no args outputs a tip" {
  run tips
  assert_success
  assert_output
}

@test "tips version outputs version string" {
  run tips version
  assert_output --partial "tips v"
}

@test "tips --version outputs version string" {
  run tips --version
  assert_output --partial "tips v"
}

@test "tips help shows usage" {
  run tips help
  assert_output --partial "Usage:"
}

@test "tips --help shows usage" {
  run tips --help
  assert_output --partial "Usage:"
}

@test "tips unknown command fails" {
  run tips bogus
  assert_failure
  assert_output --partial "unknown command"
}
