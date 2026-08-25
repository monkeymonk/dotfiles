#!/usr/bin/env bash
# tips provider: static — file-based tips

tips_provider_static_name() { echo "Static"; }
tips_provider_static_weight() { echo 30; }

tips_provider_static_list() {
  local file="${TIPS_DATA_FILE:-}"
  [[ -r "$file" ]] || return 1
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    echo "$line"
  done < "$file"
}

tips_provider_static_generate() {
  # Static tips are manually curated — nothing to generate
  return 1
}

tips_provider_static_status() {
  echo "file=$TIPS_DATA_FILE"
  if [[ -r "$TIPS_DATA_FILE" ]]; then
    echo "readable=yes"
  else
    echo "readable=no"
  fi
}

tips_provider_static_edit_path() {
  echo "$TIPS_DATA_FILE"
}

tips_register_provider static
