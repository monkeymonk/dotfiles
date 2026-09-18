# Shell-side half of `notify` (see scripts/notify).
#
# A PATH executable cannot do either of the two things this function does:
#
#   1. Read `$?`. The trailing form `long-build; notify` needs the status of
#      the command before it, and `$?` is gone by the time a child process
#      starts. A function runs in-process, so its first statement still sees
#      it — that capture MUST stay first; do not put anything ahead of it.
#
#   2. Run shell functions and builtins. `notify <cmd>` used to exec <cmd>
#      as a binary, so wrapping anything shell-defined died with exit 127
#      and reported a bogus "✗ 0s, exit 127". The wrapper now runs in this
#      shell and only delegates the alerting.
#
# Aliases still cannot be wrapped — they are expanded when a line is parsed,
# so they are invisible to `"$@"`. That case is detected and explained here
# rather than left to fail as a mystery 127.

runtime_plugin_notify() {
    notify() {
        _notify_st=$?
        _notify_no_sound=0
        _notify_no_popup=0
        _notify_sound=
        _notify_msg=

        while [ $# -gt 0 ]; do
            case "$1" in
                -s|--silent|--no-sound) _notify_no_sound=1; shift ;;
                -p|--no-popup) _notify_no_popup=1; shift ;;
                --sound)
                    [ $# -ge 2 ] || { command notify --sound; return 2; }
                    _notify_sound=$2
                    shift 2
                    ;;
                --sounds) command notify --sounds; return 0 ;;
                -m|--message)
                    # Rest of the line is the message; see scripts/notify.
                    shift
                    if [ $# -eq 0 ]; then
                        printf 'notify: -m needs a message\n' >&2
                        return 2
                    fi
                    _notify_msg=$*
                    set --
                    break
                    ;;
                --) shift; break ;;
                -h|--help) command notify --help; return 0 ;;
                -*) command notify "$1"; return 2 ;;
                *) break ;;
            esac
        done

        if [ $# -gt 0 ]; then
            if alias "$1" >/dev/null 2>&1; then
                printf "notify: '%s' is a shell alias and cannot be wrapped.\n" "$1" >&2
                printf 'notify: run it and append instead:  %s; notify\n' "$*" >&2
                return 2
            fi
            if ! command -v "$1" >/dev/null 2>&1; then
                printf "notify: '%s' is not a command.\n" "$1" >&2
                printf 'notify: to send this as a message:  notify -m %s\n' "$*" >&2
                return 127
            fi

            _notify_msg=$*
            _notify_t0=$(date +%s)
            _notify_st=0
            "$@" || _notify_st=$?
            set -- --status "$_notify_st" --took "$(($(date +%s) - _notify_t0))"
        else
            set -- --status "$_notify_st"
        fi

        # -m swallows the rest of the line, so it must be appended last.
        [ "$_notify_no_sound" -eq 1 ] && set -- "$@" --silent
        [ "$_notify_no_popup" -eq 1 ] && set -- "$@" --no-popup
        [ -n "$_notify_sound" ] && set -- "$@" --sound "$_notify_sound"
        [ -n "$_notify_msg" ] && set -- "$@" -m "$_notify_msg"
        command notify "$@"
        return "$_notify_st"
    }
}

hook_register setup runtime_plugin_notify
