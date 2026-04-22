# llama.cpp — local LLM inference (llama-cli, llama-server, llama-swap).
#
# Detects the GPU backend at load time (cuda / rocm / vulkan / metal / cpu)
# and exports LLAMA_GPU_BACKEND so helpers and build scripts can branch on
# it. Adds common llama.cpp build dirs to PATH, sets LLAMA_HOST /
# LLAMA_MODELS_DIR defaults, and wires llama-swap defaults when the proxy
# is installed.
#
# Detection-only — this plugin does not install or build anything.

runtime_plugin_llama() {
    # --- 1. PATH: common llama.cpp build/install dirs -------------------
    local _dir
    for _dir in \
        "$HOME/.local/share/llama.cpp/build/bin" \
        "$HOME/llama.cpp/build/bin" \
        "$HOME/src/llama.cpp/build/bin" \
    ; do
        [ -d "$_dir" ] && path_prepend "$_dir"
    done

    # --- 2. Presence check — skip if nothing installed ------------------
    has_cmd llama-server || has_cmd llama-cli || has_cmd llama-swap || return 0

    # --- 3. GPU backend detection ---------------------------------------
    # Explicit LLAMA_GPU_BACKEND in the environment always wins.
    if [ -z "$LLAMA_GPU_BACKEND" ]; then
        if is_mac; then
            export LLAMA_GPU_BACKEND=metal
        elif has_cmd nvidia-smi; then
            export LLAMA_GPU_BACKEND=cuda
        elif has_cmd rocminfo || [ -d /opt/rocm ]; then
            export LLAMA_GPU_BACKEND=rocm
        elif has_cmd vulkaninfo; then
            export LLAMA_GPU_BACKEND=vulkan
        else
            export LLAMA_GPU_BACKEND=cpu
        fi
    else
        export LLAMA_GPU_BACKEND
    fi

    # --- 4. Shared defaults ---------------------------------------------
    export LLAMA_MODELS_DIR="${LLAMA_MODELS_DIR:-$HOME/.local/share/llama.cpp/models}"
    export LLAMA_HOST="${LLAMA_HOST:-127.0.0.1:8080}"

    # --- 5. llama-swap wiring -------------------------------------------
    if has_cmd llama-swap; then
        export LLAMA_SWAP_CONFIG="${LLAMA_SWAP_CONFIG:-$HOME/.config/llama-swap/config.yaml}"
        alias llama-swap-up='llama-swap -config "$LLAMA_SWAP_CONFIG" -listen "$LLAMA_HOST" -watch-config' \
            --desc "Start llama-swap on \$LLAMA_HOST with \$LLAMA_SWAP_CONFIG (auto-reloads on config edits)" \
            --tags "ai,llama,llama-swap"
    fi

    # --- 6. Filesystem convenience --------------------------------------
    alias llama-models='find "$LLAMA_MODELS_DIR" -maxdepth 3 -type f -name "*.gguf" 2>/dev/null | sort' \
        --desc "List .gguf files under \$LLAMA_MODELS_DIR" \
        --tags "ai,llama,models"
}

hook_register setup runtime_plugin_llama
