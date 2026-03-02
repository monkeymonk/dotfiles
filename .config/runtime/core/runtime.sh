# Runtime-level diagnostics.

runtime_status() {
    printf 'RUNTIME_ROOT:    %s\n' "${RUNTIME_ROOT:-unset}"
    if command -v runtime_context >/dev/null 2>&1; then
        runtime_context
    fi
    printf '\nHooks:\n'
    hook_list
}
