# Starship prompt.

runtime_plugin_starship() {
    require_cmd starship || return 0

    eval "$(starship init "${SHELL_FAMILY:-sh}")"
}

hook_register interactive runtime_plugin_starship
