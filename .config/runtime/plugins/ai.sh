# AI tooling — paths, symlinks, backend-agnostic helpers.
#
# Responsibilities:
#   1. PATH additions for tool-specific bin dirs
#   2. Explicit symlink map for AI CLIs in non-standard locations
#   3. AI env, helpers, and aliases — sourced when any backend
#      (ollama / llama-server / llama-swap) is present

# --- 1. PATH additions -------------------------------------------------

_ai_register_paths() {
    local _dir
    for _dir in \
        "$HOME/.opencode/bin" \
        "$HOME/.cache/lm-studio/bin" \
    ; do
        [ -d "$_dir" ] && path_prepend "$_dir"
    done
}

# --- 2. Symlink map -----------------------------------------------------
# Format: source -> destination (symlink created in ~/.local/bin)
# Add new tools here. Source supports globs for nvm-style versioned paths.

_AI_SYMLINK_BIN="$HOME/.local/bin"

# _ai_resolve: return last existing executable match (globs expanded via eval)
_ai_resolve() {
    eval "set -- $1" 2>/dev/null
    _last=""
    for _candidate do
        [ -x "$_candidate" ] && _last="$_candidate"
    done
    [ -n "$_last" ] && printf '%s' "$_last" && return 0
    return 1
}

_ai_ensure_symlinks() {
    # Skip if stamp is fresh (< 1 day old).
    local _stamp="${XDG_CACHE_HOME:-$HOME/.cache}/runtime/ai-symlinks.stamp"
    if [ -f "$_stamp" ]; then
        local _age_ok=0
        # find returns 0 if file matches (modified within 1 day)
        find "$_stamp" -mmin -1440 -print 2>/dev/null | grep -q . && _age_ok=1
        [ "$_age_ok" -eq 1 ] && return 0
    fi

    [ -d "$_AI_SYMLINK_BIN" ] || mkdir -p "$_AI_SYMLINK_BIN"

    # tool_name  source_path (globs ok — last match wins for version sort)
    set -- \
        claude    "$HOME/.local/share/claude/versions/*" \
        gemini    "$HOME/.local/share/mise/installs/node/*/bin/gemini" \
        codex     "$HOME/.local/share/mise/installs/node/*/bin/codex" \
        opencode  "$HOME/.opencode/bin/opencode" \
        mcp-hub   "$HOME/.local/share/mise/installs/node/*/bin/mcp-hub"

    while [ $# -ge 2 ]; do
        _name="$1"; _pattern="$2"; shift 2
        has_cmd "$_name" && continue
        [ -L "$_AI_SYMLINK_BIN/$_name" ] && continue
        _src=$(_ai_resolve "$_pattern") || continue
        ln -s "$_src" "$_AI_SYMLINK_BIN/$_name"
        info "ai: symlinked $_name -> $_src"
    done

    unset _name _pattern _src _candidate
    mkdir -p "$(dirname "$_stamp")" 2>/dev/null
    touch "$_stamp"
}

# --- 3. Backend-agnostic helper setup ------------------------------------

_ai_setup() {
    # Source env + helpers if any backend is installed. The helpers
    # auto-dispatch between llama.cpp/llama-swap and ollama at call time.
    if has_cmd ollama || has_cmd llama-server || has_cmd llama-swap; then
        safe_source "${RUNTIME_ROOT}/ai/env.sh"
        safe_source "${RUNTIME_ROOT}/ai/helpers.sh"
        has_cmd ollama && export HAS_OLLAMA=1
        if command -v alx >/dev/null 2>&1; then
            safe_source "${RUNTIME_ROOT}/ai/aliases.sh"
            runtime_ai_aliases
        fi
    fi
}

# --- Entry point ----------------------------------------------------------

runtime_plugin_ai() {
    _ai_register_paths
    _ai_ensure_symlinks
    _ai_setup
}

hook_register setup runtime_plugin_ai
