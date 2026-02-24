# Go environment.

runtime_plugin_go() {
    if [ -n "${GOPATH-}" ] && [ -d "$GOPATH/bin" ]; then
        path_prepend "$GOPATH/bin"
    elif [ -d "$HOME/go/bin" ]; then
        path_prepend "$HOME/go/bin"
    fi
}

runtime_hook_register setup runtime_plugin_go
