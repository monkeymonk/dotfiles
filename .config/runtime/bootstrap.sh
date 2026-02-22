#!/usr/bin/env sh

# Single entry point for runtime environment.

# Guard against double-loading.
if [ "${RUNTIME_BOOTSTRAP_LOADED-}" = "1" ]; then
    return 0 2>/dev/null || exit 0
fi
RUNTIME_BOOTSTRAP_LOADED=1

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
    "$RUNTIME_ROOT/core/utils.sh"
do
    [ -f "$_f" ] && . "$_f"
done
unset _f

# Load plugins (alphabetical). Plugins should only register hooks.
if [ -d "$RUNTIME_ROOT/plugins" ]; then
    for _f in "$RUNTIME_ROOT"/plugins/*.sh; do
        [ -f "$_f" ] || continue
        . "$_f"

        _plugin_base=${_f##*/}
        _plugin_name=${_plugin_base%.sh}
        _plugin_fn="runtime_plugin_${_plugin_name}"
        _plugin_phase=${RUNTIME_PLUGIN_PHASE:-post_config}
        unset RUNTIME_PLUGIN_PHASE

        if command -v "$_plugin_fn" >/dev/null 2>&1; then
            if ! _runtime_hook_list_has "${RUNTIME_HOOKS_ALL-}" "$_plugin_fn"; then
                runtime_hook_register "$_plugin_phase" "$_plugin_fn"
            fi
        fi
    done
    unset _f _plugin_base _plugin_name _plugin_fn _plugin_phase
fi

# Context phase (allows plugins to register early hooks).
runtime_hook_run pre_context
if [ -f "$RUNTIME_ROOT/core/context.sh" ]; then
    . "$RUNTIME_ROOT/core/context.sh"
fi
runtime_hook_run post_context

# Load config modules.
runtime_hook_run pre_config
for _f in \
    "$RUNTIME_ROOT/config/defaults.sh" \
    "$RUNTIME_ROOT/config/exports.sh" \
    "$RUNTIME_ROOT/config/paths.sh" \
    "$RUNTIME_ROOT/config/context.sh"
do
    [ -f "$_f" ] && . "$_f"
done
unset _f
runtime_hook_run post_config

# Load machine overrides based on context.
if [ "${RUNTIME_IS_WORK-}" = "1" ] && [ -f "$RUNTIME_ROOT/config/machine/work.sh" ]; then
    . "$RUNTIME_ROOT/config/machine/work.sh"
fi
if [ "${RUNTIME_IS_HOME-}" = "1" ] && [ -f "$RUNTIME_ROOT/config/machine/home.sh" ]; then
    . "$RUNTIME_ROOT/config/machine/home.sh"
fi

# Load secrets (alphabetical). Errors must be visible.
if [ -d "$RUNTIME_ROOT/secrets" ]; then
    for _f in "$RUNTIME_ROOT"/secrets/*.sh; do
        [ -f "$_f" ] || continue
        if ! . "$_f"; then
            printf '%s\n' "runtime: warning: failed to source $_f" >&2
        fi
    done
    unset _f
fi
runtime_hook_run post_secrets

# Prepend scripts to PATH.
if [ -d "$RUNTIME_ROOT/scripts" ]; then
    path_prepend "$RUNTIME_ROOT/scripts"
fi
runtime_hook_run post_scripts

# Export aliases via alx.
if command -v alx >/dev/null 2>&1; then
    eval "$(alx export --shell)"
fi

# Source cdx if installed.
if [ -f "$HOME/.local/share/cdx/cdx.sh" ]; then
    . "$HOME/.local/share/cdx/cdx.sh"
    if command -v runtime_cdx_aliases >/dev/null 2>&1; then
        runtime_cdx_aliases
    fi
fi
runtime_hook_run late

unset _runtime_src _runtime_dir
