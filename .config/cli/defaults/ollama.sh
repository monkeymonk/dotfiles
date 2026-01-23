# defaults/ollama.sh

# Ollama (Local LLM Runtime)
if command -v ollama >/dev/null 2>&1; then
  # API endpoint (used by Neovim, OpenCode, etc.)
  export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"

  # Keep latency predictable (autocomplete-friendly)
  export OLLAMA_NUM_PARALLEL="${OLLAMA_NUM_PARALLEL:-1}"
  export OLLAMA_MAX_LOADED_MODELS="${OLLAMA_MAX_LOADED_MODELS:-1}"

  # Logging (avoid noise)
  export OLLAMA_LOG_LEVEL="${OLLAMA_LOG_LEVEL:-warn}"

  # Allow full GPU usage (safe on single-user machines)
  export OLLAMA_GPU_OVERHEAD="${OLLAMA_GPU_OVERHEAD:-64}"

  # Optional: model storage location
  # export OLLAMA_MODELS="${OLLAMA_MODELS:-$HOME/.ollama/models}"
fi
