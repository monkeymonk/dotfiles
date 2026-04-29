# Ollama — storage path, host, convenience aliases.
#
# Detection-only — does not install Ollama. Mirrors plugins/llama.sh:
# pin the model store under /data/models when present so big blobs stay
# off the home filesystem, and expose a small set of aliases to start
# the daemon and inspect installed models.

runtime_plugin_ollama() {
    has_cmd ollama || return 0

    # Pin the blob store to /data/models/ollama when present. Without
    # this, ollama writes to ~/.ollama/models (home filesystem).
    if [ -z "$OLLAMA_MODELS" ] && [ -d /data/models ]; then
        export OLLAMA_MODELS=/data/models/ollama
    fi

    # Bind address for `ollama serve` and the CLI client. ai/env.sh sets
    # the same default — exporting here too keeps the plugin usable in
    # contexts where ai/env.sh hasn't been sourced yet.
    export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"

    alias ollama-up='nohup ollama serve >"${XDG_STATE_HOME:-$HOME/.local/state}/ollama.log" 2>&1 & disown 2>/dev/null || true' \
        --desc "Start \`ollama serve\` in background (logs: \$XDG_STATE_HOME/ollama.log)" \
        --tags "ai,ollama"

    alias ollama-models='ollama list' \
        --desc "List installed ollama models" \
        --tags "ai,ollama,models"
}

hook_register setup runtime_plugin_ollama
