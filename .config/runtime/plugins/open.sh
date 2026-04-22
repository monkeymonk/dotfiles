# Cross-platform `open` shim.
#
# macOS ships `open`; Linux does not. Define a shell function that dispatches
# URLs through $BROWSER and filesystem paths through xdg-open. Skips cleanly
# when the platform already provides a native `open`.

runtime_plugin_open() {
    command -v open >/dev/null 2>&1 && return 0
    require_cmd xdg-open || return 0

    open() {
        if [ $# -eq 0 ]; then
            printf 'usage: open <file|dir|url> [...]\n' >&2
            return 1
        fi
        for _target in "$@"; do
            case "$_target" in
                http://*|https://*|ftp://*|file://*|mailto:*|ssh://*)
                    if [ -n "${BROWSER-}" ] && command -v "${BROWSER%% *}" >/dev/null 2>&1; then
                        # shellcheck disable=SC2086
                        ${BROWSER} "$_target" >/dev/null 2>&1 &
                    else
                        xdg-open "$_target" >/dev/null 2>&1 &
                    fi
                    ;;
                *)
                    if [ ! -e "$_target" ]; then
                        printf 'open: no such file or directory: %s\n' "$_target" >&2
                        return 1
                    fi
                    xdg-open "$_target" >/dev/null 2>&1 &
                    ;;
            esac
        done
    }
}

hook_register setup runtime_plugin_open
