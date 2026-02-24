# Logging helpers (TTY-only, colorized when possible).

__runtime_log_enabled() {
    [ -t 1 ] && [ -n "${TERM-}" ] && [ "${TERM}" != "dumb" ]
}

__runtime_log_colors() {
    if __runtime_log_enabled; then
        _C_RESET=$(printf '\033[0m')
        _C_INFO=$(printf '\033[34m')
        _C_SUCCESS=$(printf '\033[32m')
        _C_WARN=$(printf '\033[33m')
        _C_ERROR=$(printf '\033[31m')
    else
        _C_RESET=""
        _C_INFO=""
        _C_SUCCESS=""
        _C_WARN=""
        _C_ERROR=""
    fi
}

__runtime_log_colors

info() {
    __runtime_log_enabled || return 0
    printf '%s\n' "${_C_INFO}info:${_C_RESET} $*"
}

success() {
    __runtime_log_enabled || return 0
    printf '%s\n' "${_C_SUCCESS}success:${_C_RESET} $*"
}

warn() {
    if __runtime_log_enabled; then
        printf '%s\n' "${_C_WARN}warn:${_C_RESET} $*" >&2
    else
        printf 'warn: %s\n' "$*" >&2
    fi
}

error() {
    if __runtime_log_enabled; then
        printf '%s\n' "${_C_ERROR}error:${_C_RESET} $*" >&2
    else
        printf 'error: %s\n' "$*" >&2
    fi
}
