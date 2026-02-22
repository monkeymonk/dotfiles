# Rust environment.

runtime_plugin_rust() {
    if [ -d "$HOME/.cargo" ] || has_cmd cargo; then
        export CARGO_HOME="$HOME/.cargo"
        if [ -d "$CARGO_HOME/bin" ]; then
            path_prepend "$CARGO_HOME/bin"
        fi
        if [ -f "$CARGO_HOME/env" ]; then
            # shellcheck disable=SC1090
            . "$CARGO_HOME/env"
        fi
    fi

    if [ -d "$HOME/.rustup" ] || has_cmd rustup; then
        export RUSTUP_HOME="$HOME/.rustup"
    fi
}

runtime_hook_register post_config runtime_plugin_rust
