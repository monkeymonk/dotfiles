# yazi — terminal file manager with cd-on-exit wrapper.

runtime_plugin_yazi() {
    has_cmd yazi || return 0

    y() {
        local target
        target=$(command yazi-launch "$@") || return $?
        if [ -n "$target" ] && [ -d "$target" ]; then
            builtin cd -- "$target"
        fi
    }
}

hook_register setup runtime_plugin_yazi
