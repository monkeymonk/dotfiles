# AI/LLM env — backend selection + role → model mapping.
#
# Sourced by plugins/ai.sh when any AI backend (llama-server / llama-swap
# or ollama) is installed. Declarative only; all dispatch lives in
# ai/helpers.sh.
#
# Backend:
#   AI_BACKEND=auto    → helpers auto-pick (llama-swap if up, else ollama)
#   AI_BACKEND=llama   → force llama.cpp / llama-swap OpenAI-compat API
#   AI_BACKEND=ollama  → force ollama
#
# Roles (what helpers ask for):
#   default  — general-purpose
#   code     — heavy code generation / refactor
#   reason   — review, debug, security audits
#   fast     — commit messages, short explanations
#   embed    — embeddings
#   vision   — image analysis (backend must support vision)
#   ocr      — text extraction from images (backend must support vision)
#
# A single namespace (AI_MODEL_*) is used for both backends. Point each
# role at whatever the active backend expects:
#   - llama-swap  → the alias names declared in ~/.config/llama-swap/config.yaml
#   - ollama      → full tags, e.g. "qwen2.5-coder:7b"

: "${AI_BACKEND:=auto}"

# Auto-start llama-swap in the background on first use if it isn't running.
# Set to 0 to disable (e.g. on a managed server where the proxy is a
# systemd unit).
: "${AI_AUTOSTART:=1}"

# ── Role → model-id ───────────────────────────────────────────────────────
# Defaults match llama-swap alias conventions. Override in secrets or
# machine-specific config if targeting ollama (full tags) or custom aliases.
: "${AI_MODEL_DEFAULT:=default}"
: "${AI_MODEL_CODE:=code}"
: "${AI_MODEL_REASON:=reason}"
: "${AI_MODEL_FAST:=fast}"
: "${AI_MODEL_EMBED:=embed}"
: "${AI_MODEL_VISION:=vision}"
: "${AI_MODEL_OCR:=ocr}"

# ── Endpoints ─────────────────────────────────────────────────────────────
# LLAMA_HOST is set by plugins/llama.sh (default 127.0.0.1:8080).
export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
