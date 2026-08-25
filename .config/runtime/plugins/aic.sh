# aic — AI tooling configuration manager (Go).
#
# Source checkout:
#   ~/Works/tools/aic-workspace/aic
#
# Canonical sources live in package repositories registered in
# ~/.config/aic/aic.toml; rendered output goes to ~/.config/aic/generated/.
#
# Replaces the legacy ai-capabilities experiment. While plugins/ai-capabilities.sh
# still exists it defines an `aic` alias that would shadow this binary, so the
# alias is cleared here — this plugin loads after it.

runtime_plugin_aic() {
    local _source
    _source="${AIC_SOURCE:-$HOME/Works/tools/aic-workspace/aic}"

    [ -x "$_source/bin/aic" ] || return 0

    export AIC_SOURCE="$_source"
    unalias aic 2>/dev/null
    path_prepend "$_source/bin"
}

hook_register setup runtime_plugin_aic
