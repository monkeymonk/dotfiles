# UV Python package manager.

runtime_plugin_uv() {
    require_cmd uv || return 0

    path_prepend "$HOME/.local/bin"
    export UV_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/uv"

    case ${-:-} in *i*)
        case "${SHELL_FAMILY-}" in
            zsh|bash)
                local _uv_cache="${XDG_CACHE_HOME:-$HOME/.cache}/runtime/uv-completion.${SHELL_FAMILY}"
                local _uv_bin
                _uv_bin=$(command -v uv 2>/dev/null)
                # Regenerate only if cache missing or uv binary is newer than cache.
                if [ ! -f "$_uv_cache" ] || { [ -n "$_uv_bin" ] && [ "$_uv_bin" -nt "$_uv_cache" ]; }; then
                    mkdir -p "$(dirname "$_uv_cache")" 2>/dev/null
                    uv generate-shell-completion "$SHELL_FAMILY" > "$_uv_cache" 2>/dev/null
                fi
                safe_source "$_uv_cache"
                ;;
        esac ;;
    esac
}

hook_register setup runtime_plugin_uv
