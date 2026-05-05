# AI tooling — paths and backend-agnostic helpers.
#
# Symlinks for AI CLIs in non-standard locations are managed by
# scripts/ai-symlinks-refresh (also runnable manually after installs).

_ai_register_paths() {
    local _dir
    for _dir in \
        "$HOME/.opencode/bin" \
        "$HOME/.cache/lm-studio/bin" \
    ; do
        [ -d "$_dir" ] && path_prepend "$_dir"
    done
}

_ai_setup() {
    # Source env + helpers if any backend is installed. The helpers
    # auto-dispatch between llama.cpp/llama-swap and ollama at call time.
    if has_cmd ollama || has_cmd llama-server || has_cmd llama-swap; then
        safe_source "${RUNTIME_ROOT}/ai/env.sh"
        safe_source "${RUNTIME_ROOT}/ai/helpers.sh"
        # alx is optional — its alias() shim (plugins/alx.sh) strips
        # --desc/--tags when alx is absent, so the registrations work
        # either way.
        safe_source "${RUNTIME_ROOT}/ai/aliases.sh"
        runtime_ai_aliases
    fi
}

runtime_plugin_ai() {
    _ai_register_paths
    has_cmd ai-symlinks-refresh && ai-symlinks-refresh
    _ai_setup
}

hook_register setup runtime_plugin_ai
