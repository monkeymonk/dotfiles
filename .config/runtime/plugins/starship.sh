# Starship prompt.

runtime_plugin_starship() {
    require_cmd starship || return 0

    eval "$(starship init "${SHELL_FAMILY:-sh}")"
}

runtime_hook_register late runtime_plugin_starship
