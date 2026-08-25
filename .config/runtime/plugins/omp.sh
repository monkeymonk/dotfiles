# oh-my-pi (omp) — terminal coding agent.
#
# https://github.com/can1357/oh-my-pi
#
# omp generates its completion script from live command/flag metadata, which
# costs ~0.5-0.7s. The output is cached and regenerated only when the binary is
# newer than the cache (same pattern as plugins/uv.sh).

runtime_plugin_omp() {
    # Completions are interactive-only; `hook_run interactive` is unconditional.
    case ${-:-} in
    *i*) ;;
    *) return 0 ;;
    esac

    has_cmd omp || return 0

    case "${SHELL_FAMILY-}" in
        zsh|bash) ;;
        *) return 0 ;;
    esac

    local _cache="${XDG_CACHE_HOME:-$HOME/.cache}/runtime/omp-completion.${SHELL_FAMILY}"
    local _bin
    _bin=$(command -v omp 2>/dev/null)
    if [ ! -f "$_cache" ] || { [ -n "$_bin" ] && [ "$_bin" -nt "$_cache" ]; }; then
        mkdir -p "$(dirname "$_cache")" 2>/dev/null
        omp completions "$SHELL_FAMILY" > "$_cache" 2>/dev/null || rm -f "$_cache"
    fi
    safe_source "$_cache"
}

hook_register interactive runtime_plugin_omp
