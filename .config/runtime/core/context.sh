# Runtime context detection.

: "${RUNTIME_MACHINE:=${HOSTNAME:-unknown}}"
RUNTIME_HOST="${RUNTIME_MACHINE}"

if command -v hostname >/dev/null 2>&1; then
    RUNTIME_HOST=$(hostname -s 2>/dev/null || hostname 2>/dev/null || printf '%s' "$RUNTIME_MACHINE")
fi

case "${OSTYPE-}" in
    darwin*) RUNTIME_OS="mac" ;;
    linux*) RUNTIME_OS="linux" ;;
    *) RUNTIME_OS="unknown" ;;
esac

RUNTIME_DISTRO=""
if [ "$RUNTIME_OS" = "linux" ] && [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    RUNTIME_DISTRO="${ID-}"
fi

if [ -n "${ZSH_VERSION-}" ]; then
    SHELL_FAMILY="zsh"
elif [ -n "${BASH_VERSION-}" ]; then
    SHELL_FAMILY="bash"
else
    SHELL_FAMILY="sh"
fi

# Context classification (override with RUNTIME_MACHINE_TYPE or RUNTIME_CONTEXT).
RUNTIME_IS_WORK=0
RUNTIME_IS_HOME=0

case "${RUNTIME_MACHINE_TYPE-}${RUNTIME_CONTEXT-}" in
    *work*) RUNTIME_IS_WORK=1 ;;
    *home*) RUNTIME_IS_HOME=1 ;;
esac

if [ "$RUNTIME_IS_WORK" -eq 0 ] && [ "$RUNTIME_IS_HOME" -eq 0 ]; then
    case "$RUNTIME_MACHINE" in
        work|*work*) RUNTIME_IS_WORK=1 ;;
        home|*home*) RUNTIME_IS_HOME=1 ;;
    esac
fi
