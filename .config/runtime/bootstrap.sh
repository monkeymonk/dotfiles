#!/usr/bin/env sh

# Single entry point for runtime environment.

# Guard against double-loading in the same shell (except explicit reloads).
if [ "${RUNTIME_BOOTSTRAP_LOADED-}" = "$$" ]; then
    if [ "${RUNTIME_BOOTSTRAP_RELOAD-}" != "1" ]; then
        return 0 2>/dev/null || exit 0
    fi
fi
RUNTIME_BOOTSTRAP_LOADED=$$
unset RUNTIME_BOOTSTRAP_RELOAD

# Resolve RUNTIME_ROOT without external commands.
if [ -n "${ZSH_VERSION-}" ]; then
    _runtime_src="${(%):-%N}"
else
    _runtime_src="${BASH_SOURCE[0]:-$0}"
fi

_runtime_dir=${_runtime_src%/*}
if [ "$_runtime_dir" = "$_runtime_src" ]; then
    _runtime_dir="."
fi

case "$_runtime_dir" in
    /*) RUNTIME_ROOT="$_runtime_dir" ;;
    *) RUNTIME_ROOT="$PWD/$_runtime_dir" ;;
esac
RUNTIME_ROOT=${RUNTIME_ROOT%/}

# Load core modules (deterministic order).
for _f in \
    "$RUNTIME_ROOT/core/env.sh" \
    "$RUNTIME_ROOT/core/log.sh" \
    "$RUNTIME_ROOT/core/hooks.sh" \
    "$RUNTIME_ROOT/core/path.sh" \
    "$RUNTIME_ROOT/core/prompt.sh" \
    "$RUNTIME_ROOT/core/system.sh" \
    "$RUNTIME_ROOT/core/utils.sh" \
    "$RUNTIME_ROOT/core/lazy.sh" \
    "$RUNTIME_ROOT/core/registry.sh" \
    "$RUNTIME_ROOT/core/runtime.sh"
do
    if [ ! -f "$_f" ]; then
        printf 'runtime: missing core: %s\n' "$_f" >&2
    elif ! . "$_f"; then
        printf 'runtime: failed to source: %s\n' "$_f" >&2
    fi
done
unset _f

# Load plugins (alphabetical). Plugins should only register hooks.
if [ -d "$RUNTIME_ROOT/plugins" ]; then
    for _f in "$RUNTIME_ROOT"/plugins/*.sh; do
        [ -f "$_f" ] || continue
        . "$_f"
    done
    unset _f
fi

# Context phase (allows plugins to register early hooks).
hook_run bootstrap
if [ -f "$RUNTIME_ROOT/core/context.sh" ]; then
    . "$RUNTIME_ROOT/core/context.sh"
fi
hook_run context

# Load config modules.
for _f in \
    "$RUNTIME_ROOT/config/defaults.sh" \
    "$RUNTIME_ROOT/config/exports.sh" \
    "$RUNTIME_ROOT/config/paths.sh" \
    "$RUNTIME_ROOT/config/context.sh" \
    "$RUNTIME_ROOT/config/aliases.sh"
do
    [ -f "$_f" ] && . "$_f"
done
unset _f
hook_run setup

# Load machine overrides based on context.
if [ "${RUNTIME_IS_WORK-}" = "1" ] && [ -f "$RUNTIME_ROOT/config/machine/work.sh" ]; then
    . "$RUNTIME_ROOT/config/machine/work.sh"
fi
if [ "${RUNTIME_IS_HOME-}" = "1" ] && [ -f "$RUNTIME_ROOT/config/machine/home.sh" ]; then
    . "$RUNTIME_ROOT/config/machine/home.sh"
fi

# Load secrets (alphabetical). Errors must be visible.
if [ -d "$RUNTIME_ROOT/secrets" ]; then
    if [ "${SHELL_FAMILY-}" = "zsh" ]; then
        setopt LOCAL_OPTIONS NULL_GLOB
    fi
    for _f in "$RUNTIME_ROOT"/secrets/*.env; do
        [ -f "$_f" ] || continue
        if ! . "$_f"; then
            warn "failed to source $_f"
        fi
    done
    unset _f
fi
hook_run post_secrets

# Prepend scripts to PATH.
if [ -d "$RUNTIME_ROOT/scripts" ]; then
    path_prepend "$RUNTIME_ROOT/scripts"
fi

# Source cdx if installed.
if [ -f "$HOME/.local/share/cdx/cdx.sh" ]; then
    . "$HOME/.local/share/cdx/cdx.sh"
    if command -v runtime_cdx_aliases >/dev/null 2>&1; then
        runtime_cdx_aliases
    fi
fi
hook_run interactive

# Final PATH cleanup (some external scripts append without de-duping).
path_dedupe

_runtime_reset_state() {
    # Clear hook registry so plugins re-register cleanly.
    if [ "${SHELL_FAMILY-}" = "zsh" ]; then
        setopt LOCAL_OPTIONS SH_WORD_SPLIT
    fi
    for _phase in $_HOOKS_PHASES; do
        eval "_HOOKS_${_phase}=''"
    done
    _HOOKS_PHASES=""

    # Clear all plugin *_LOADED guards.
    unset RUNTIME_TMUX_ALIASES_LOADED 2>/dev/null
    unset RUNTIME_NEOVIM_ALIASES_LOADED 2>/dev/null
    unset RUNTIME_EZA_ALIASES_LOADED 2>/dev/null
    unset RUNTIME_CDX_ALIASES_LOADED 2>/dev/null
    unset RUNTIME_AI_ALIASES_LOADED 2>/dev/null

    # Clear bootstrap guard so it re-runs.
    unset RUNTIME_BOOTSTRAP_LOADED
}

runtime_reload() {
    case "${1:-hard}" in
        soft)
            _runtime_reset_state
            RUNTIME_BOOTSTRAP_RELOAD=1
            case "${SHELL_FAMILY:-}" in
                zsh)  [ -f "$HOME/.zshrc" ]  && . "$HOME/.zshrc"  ;;
                bash) [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc" ;;
            esac
            unset RUNTIME_BOOTSTRAP_RELOAD
            ;;
        hard|*)
            exec "${SHELL:-sh}" -l
            ;;
    esac
}

alias reload='runtime_reload' --desc "Reload shell config (soft|hard)" --tags "shell,runtime"

unset _runtime_src _runtime_dir
