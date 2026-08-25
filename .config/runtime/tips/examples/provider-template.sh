#!/usr/bin/env bash
# tips provider template — copy to $TIPS_CONFIG_DIR/providers/<name>.sh and edit.
#
# A provider is a shell file that defines `tips_provider_<name>_*` functions
# and ends with `tips_register_provider <name>`. The provider name must match
# the function prefix.
#
# Provider interface (all functions are optional except `name` and `list`):
#
#   tips_provider_<name>_name        prints display name (e.g. "Fortune")
#   tips_provider_<name>_list        prints tips, one per line
#   tips_provider_<name>_weight      prints 0-100 (default: 50)
#   tips_provider_<name>_generate    refresh tips for $1 (a directory); print summary
#   tips_provider_<name>_status      prints key=value diagnostic lines
#   tips_provider_<name>_edit_path   prints a file path for `tips edit <name>`
#
# Conventions:
# - Use $TIPS_CONFIG_DIR for config, $TIPS_DATA_DIR for data, $TIPS_CACHE_DIR for caches.
# - Gate external dependencies with `command -v <cmd> &>/dev/null` and degrade gracefully
#   (return non-zero from `list` and 0 weight when unavailable).
# - Skip blank lines and lines starting with # in any tips you emit.

# Replace "example" everywhere with your provider name.
NAME="example"

# ---- example: read tips from a custom file with optional command-line filtering ----

: "${TIPS_EXAMPLE_FILE:=$TIPS_CONFIG_DIR/example-tips.txt}"

tips_provider_example_name() { echo "Example"; }

tips_provider_example_weight() {
  [[ -r "$TIPS_EXAMPLE_FILE" ]] && echo 40 || echo 0
}

tips_provider_example_list() {
  [[ -r "$TIPS_EXAMPLE_FILE" ]] || return 1
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    echo "$line"
  done < "$TIPS_EXAMPLE_FILE"
}

tips_provider_example_status() {
  echo "file=$TIPS_EXAMPLE_FILE"
  [[ -r "$TIPS_EXAMPLE_FILE" ]] && echo "readable=yes" || echo "readable=no"
}

tips_provider_example_edit_path() { echo "$TIPS_EXAMPLE_FILE"; }

tips_register_provider example
