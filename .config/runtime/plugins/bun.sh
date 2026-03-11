# Bun environment.

runtime_plugin_bun() {
  if [ -d "$HOME/.bun" ] || has_cmd bun; then
    export BUN_INSTALL="$HOME/.bun"
    if [ -d "$BUN_INSTALL/bin" ]; then
      path_prepend "$BUN_INSTALL/bin"
    fi

    # bun completions
    if [ -s "$BUN_INSTALL/_bun" ]; then
      safe_source "$BUN_INSTALL/_bun"
    fi
  fi
}

hook_register setup runtime_plugin_bun
