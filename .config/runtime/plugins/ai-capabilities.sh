# ai-capabilities — activate generated AI tooling bundle.
#
# Source checkout:
#   ~/Works/tools/ai-capabilities
#
# Runtime state:
#   ~/.config/ai-capabilities/current -> ~/.cache/ai-capabilities/builds/<profile>/<hash>

_ai_capabilities_find_source() {
    if [ -n "${AI_CAPABILITIES_SOURCE-}" ]; then
        printf '%s\n' "$AI_CAPABILITIES_SOURCE"
        return 0
    fi
    if [ -d "$HOME/Works/tools/ai-capabilities" ]; then
        printf '%s\n' "$HOME/Works/tools/ai-capabilities"
        return 0
    fi
    return 1
}

_ai_capabilities_link() {
    local _source _target
    _source=$1
    _target=$2

    [ -e "$_source" ] || return 0

    if [ -L "$_target" ]; then
        [ "$(readlink "$_target")" = "$_source" ] && return 0
        command rm -f "$_target"
    elif [ -e "$_target" ]; then
        return 0
    fi

    mkdir -p "${_target%/*}"
    ln -s "$_source" "$_target"
}

_ai_capabilities_link_codex() {
    local _codex
    _codex="$AI_CAPABILITIES_HOME/providers/codex"
    [ -d "$_codex" ] || return 0

    _ai_capabilities_link "$_codex/skills" "$HOME/.codex/skills"
    _ai_capabilities_link "$_codex/rules" "$HOME/.codex/rules"
}

runtime_plugin_ai_capabilities() {
    guard_double_load RUNTIME_AI_CAPABILITIES_LOADED || return 0

    local _source _home _current _env
    _home="${AI_CAPABILITIES_CONFIG_HOME:-$HOME/.config/ai-capabilities}"
    _current="$_home/current"
    _env="$_current/env/shell.env"

    if _source=$(_ai_capabilities_find_source); then
        export AI_CAPABILITIES_SOURCE="$_source"
        if [ -x "$_source/scripts/aic" ]; then
            alias aic='"$AI_CAPABILITIES_SOURCE/scripts/aic"' \
                --desc "ai-capabilities CLI" --tags "ai,capabilities"
            alias aic-build='"$AI_CAPABILITIES_SOURCE/scripts/aic" build "${AI_PROFILE:-local-first}"' \
                --desc "Build active ai-capabilities profile" --tags "ai,capabilities,build"
            alias aic-activate='"$AI_CAPABILITIES_SOURCE/scripts/aic" activate "${AI_PROFILE:-local-first}"' \
                --desc "Build and activate active ai-capabilities profile" --tags "ai,capabilities,activate"
            alias aic-status='"$AI_CAPABILITIES_SOURCE/scripts/aic" status' \
                --desc "Show ai-capabilities runtime status" --tags "ai,capabilities,status"
        fi
    fi

    # Generated env is intentionally static: simple export lines only.
    safe_source "$_env" || return 0

    [ -d "$AI_CAPABILITIES_HOME/bin" ] && path_prepend "$AI_CAPABILITIES_HOME/bin"
    _ai_capabilities_link_codex
}

hook_register setup runtime_plugin_ai_capabilities
