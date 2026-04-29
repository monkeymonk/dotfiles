# Override TERM for ssh sessions.
#
# Ghostty sets TERM=xterm-ghostty, which most remote hosts don't have a
# terminfo entry for, breaking `clear`, vim colors, etc. Downgrade to
# xterm-256color only for ssh invocations so local sessions keep full fidelity.

runtime_plugin_ssh() {
    has_cmd ssh || return 0

    ssh() { TERM=xterm-256color command ssh "$@"; }
}

hook_register setup runtime_plugin_ssh
