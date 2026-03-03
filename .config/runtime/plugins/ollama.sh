# Ollama integration.

runtime_plugin_ollama() {
    require_cmd ollama || return 0

    export HAS_OLLAMA=1
    : "${OLLAMA_MODEL:=qwen2.5-coder:7b}"
    : "${OLLAMA_MODEL_CODE:=qwen3-coder:30b}"
    : "${OLLAMA_MODEL_REASON:=qwen3.5:35b}"
    : "${OLLAMA_MODEL_FAST:=qwen3.5:9b}"
    : "${OLLAMA_MODEL_OCR:=glm-ocr:latest}"
    : "${OLLAMA_MODEL_VISION:=llama3.2-vision:11b}"
    : "${OLLAMA_MODEL_EMBED:=nomic-embed-text:latest}"
    : "${OLLAMA_MODEL_THINK:=lfm2.5-thinking:latest}"
    : "${OLLAMA_MODEL_FLASH:=glm-4.7-flash:latest}"

    export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
    export OLLAMA_NUM_PARALLEL="${OLLAMA_NUM_PARALLEL:-1}"
    export OLLAMA_MAX_LOADED_MODELS="${OLLAMA_MAX_LOADED_MODELS:-1}"
    export OLLAMA_LOG_LEVEL="${OLLAMA_LOG_LEVEL:-warn}"
    export OLLAMA_GPU_OVERHEAD="${OLLAMA_GPU_OVERHEAD:-64}"
    # Optional:
    # export OLLAMA_MODELS="${OLLAMA_MODELS:-$HOME/.ollama/models}"

    # Load helper functions and register aliases.
    local _helpers
    _helpers="${RUNTIME_ROOT}/plugins/ollama-helpers.sh"
    if [ -f "$_helpers" ]; then
        . "$_helpers"
        command -v alx >/dev/null 2>&1 && runtime_ollama_aliases
    fi
}

hook_register setup runtime_plugin_ollama
