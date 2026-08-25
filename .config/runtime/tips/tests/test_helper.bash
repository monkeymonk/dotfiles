load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

TIPS_ROOT="$BATS_TEST_DIRNAME/.."

setup_tips() {
  export TIPS_CONFIG_DIR="$BATS_TMPDIR/tips-config-$$"
  export TIPS_DATA_FILE="$BATS_TMPDIR/tips-data-$$.txt"
  mkdir -p "$TIPS_CONFIG_DIR/providers"

  # Create a minimal static tips file
  cat > "$TIPS_DATA_FILE" <<'EOF'
# test tips
tip one
tip two
tip three
EOF

  # Reset provider array and load tips
  unset __TIPS_PROVIDERS
  source "$TIPS_ROOT/tips.sh"
}
