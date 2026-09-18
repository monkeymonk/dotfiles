# Shell-side wiring for the nvim-scratch persistent scratchpad (see
# scripts/nvim-scratch for the actual server/client logic).
#
# This plugin defines NO defaults for any NVIM_SCRATCH_* variable. The
# server survives the tmux server and the shell that spawned it, so by the
# time this plugin loads in some later shell, an already-running instance's
# environment was frozen at spawn time under whatever defaults
# scripts/nvim-scratch applied back then. Defaulting anything here would
# just be a second, driftable copy of that logic — the script alone owns
# its defaults.

_runtime_resolve_scratch_running() {
    # Cheap: counts *.sock files. Never spawns nvim to probe — this runs
    # during shell startup and must stay fast.
    if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
        _rs_dir="$XDG_RUNTIME_DIR/nvim-scratch"
    else
        _rs_dir="${TMPDIR:-/tmp}/nvim-scratch-$(id -u)"
    fi

    _rs_n=0
    if [ -d "$_rs_dir" ]; then
        for _rs_f in "$_rs_dir"/*.sock; do
            [ -e "$_rs_f" ] || continue
            _rs_n=$((_rs_n + 1))
        done
    fi

    if [ "$_rs_n" -gt 0 ]; then
        RUNTIME_SCRATCH_RUNNING=yes
    else
        RUNTIME_SCRATCH_RUNNING=no
    fi
    export RUNTIME_SCRATCH_RUNNING
    unset _rs_dir _rs_n _rs_f
}

runtime_plugin_nvim_scratch() {
    has_cmd nvim || return 0
    command -v alx >/dev/null 2>&1 && alias scratch='nvim-scratch' --desc "Toggle the persistent nvim scratchpad" --tags "nvim,scratch,notes"
    ctx_set_lazy RUNTIME_SCRATCH_RUNNING _runtime_resolve_scratch_running plugin
}

hook_register setup runtime_plugin_nvim_scratch
