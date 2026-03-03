# Ollama integration — thin shim loading ai/ module.

runtime_plugin_ollama() {
    require_cmd ollama || return 0
    export HAS_OLLAMA=1
    safe_source "${RUNTIME_ROOT}/ai/env.sh"
    safe_source "${RUNTIME_ROOT}/ai/helpers.sh"
    command -v alx >/dev/null 2>&1 && {
        safe_source "${RUNTIME_ROOT}/ai/aliases.sh"
        runtime_ai_aliases
    }
}

hook_register setup runtime_plugin_ollama
