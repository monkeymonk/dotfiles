#!/usr/bin/env bats
load '../tests/test_helper'

setup() { setup_tips; }

@test "tips count shows per-provider counts" {
  run tips count
  assert_success
  assert_output --partial "Static"
}

@test "tips count --source static filters to static only" {
  run tips count --source static
  assert_success
  assert_output --partial "Static"
  refute_output --partial "total"
}

@test "tips sources lists registered providers" {
  run tips sources
  assert_success
  assert_output --partial "static"
}

@test "tips status shows config paths" {
  run tips status
  assert_success
  assert_output --partial "Config dir:"
  assert_output --partial "Providers:"
}

@test "tips list shows tips grouped by provider" {
  run tips list
  assert_success
  assert_output --partial "[Static]"
  assert_output --partial "tip one"
}

@test "tips list --source static filters to static only" {
  run tips list --source static
  assert_success
  assert_output --partial "tip one"
}

@test "tips list --source nonexistent shows nothing" {
  run tips list --source nonexistent
  assert_success
  refute_output --partial "tip"
}

@test "tips refresh reports provider status" {
  run tips refresh
  assert_success
  # static provider has no generator
  assert_output --partial "Static"
}

@test "tips edit with unknown provider fails" {
  run tips edit nonexistent
  assert_failure
  assert_output --partial "no editable file"
}
