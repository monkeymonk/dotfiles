# Runtime context detection.

registry_init CTX

ctx_set() {
    eval "$1=\"$2\""; export "$1"
    registry_add CTX "$1" "${3:-_}"
}

ctx_set_lazy() {
    registry_add_lazy CTX "$1" "$2" "${3:-_}"
}

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

ctx_set RUNTIME_OS "$RUNTIME_OS" system
ctx_set RUNTIME_HOST "$RUNTIME_HOST" system
ctx_set RUNTIME_DISTRO "$RUNTIME_DISTRO" system
ctx_set SHELL_FAMILY "$SHELL_FAMILY" session

# Context classification.
# Priority order:
#   1. Explicit env: RUNTIME_MACHINE_TYPE or RUNTIME_CONTEXT
#   2. Dotfile: $RUNTIME_ROOT/context (contains "work" or "home")
#   3. Hostname pattern match (word-boundary anchored, least specific)
RUNTIME_IS_WORK=0
RUNTIME_IS_HOME=0

case "${RUNTIME_MACHINE_TYPE-}${RUNTIME_CONTEXT-}" in
    *work*) RUNTIME_IS_WORK=1 ;;
    *home*) RUNTIME_IS_HOME=1 ;;
esac

if [ "$RUNTIME_IS_WORK" -eq 0 ] && [ "$RUNTIME_IS_HOME" -eq 0 ]; then
    _ctx_file="${RUNTIME_ROOT}/context"
    if [ -f "$_ctx_file" ]; then
        read -r _ctx_val < "$_ctx_file"
        case "${_ctx_val-}" in
            work) RUNTIME_IS_WORK=1 ;;
            home) RUNTIME_IS_HOME=1 ;;
        esac
        unset _ctx_val
    fi
    unset _ctx_file
fi

if [ "$RUNTIME_IS_WORK" -eq 0 ] && [ "$RUNTIME_IS_HOME" -eq 0 ]; then
    case "$RUNTIME_HOST" in
        work|work-*|*-work) RUNTIME_IS_WORK=1 ;;
        home|home-*|*-home) RUNTIME_IS_HOME=1 ;;
    esac
fi

ctx_set RUNTIME_IS_WORK "$RUNTIME_IS_WORK" system
ctx_set RUNTIME_IS_HOME "$RUNTIME_IS_HOME" system

# CI detection.
RUNTIME_IS_CI=0
if [ "${CI-}" = "true" ] || [ -n "${GITHUB_ACTIONS-}" ] || [ -n "${GITLAB_CI-}" ] || \
   [ -n "${TRAVIS-}" ] || [ -n "${CIRCLECI-}" ]; then
    RUNTIME_IS_CI=1
fi
ctx_set RUNTIME_IS_CI "$RUNTIME_IS_CI" session

# Container detection.
RUNTIME_IS_CONTAINER=0
if [ -f /.dockerenv ]; then
    RUNTIME_IS_CONTAINER=1
elif [ "${DOCKER_CONTAINER-}" = "1" ]; then
    RUNTIME_IS_CONTAINER=1
elif [ -r /proc/1/cgroup ]; then
    while IFS= read -r _cgroup_content; do
        case "$_cgroup_content" in
            *docker*|*lxc*|*containerd*) RUNTIME_IS_CONTAINER=1; break ;;
        esac
    done < /proc/1/cgroup
    unset _cgroup_content
fi
ctx_set RUNTIME_IS_CONTAINER "$RUNTIME_IS_CONTAINER" session

# Session type detection.
case "${XDG_SESSION_TYPE-}" in
    x11|wayland|tty|mir)
        RUNTIME_SESSION_TYPE="${XDG_SESSION_TYPE}" ;;
    *)
        if [ -n "${WAYLAND_DISPLAY-}" ]; then
            RUNTIME_SESSION_TYPE="wayland"
        elif [ -n "${DISPLAY-}" ]; then
            RUNTIME_SESSION_TYPE="x11"
        else
            RUNTIME_SESSION_TYPE="tty"
        fi
        ;;
esac
ctx_set RUNTIME_SESSION_TYPE "$RUNTIME_SESSION_TYPE" session

# Server detection: Linux with no graphical session.
RUNTIME_IS_SERVER=0
if [ "$RUNTIME_OS" = "linux" ] && [ "$RUNTIME_SESSION_TYPE" = "tty" ] && \
   [ -z "${DISPLAY-}" ] && [ -z "${WAYLAND_DISPLAY-}" ]; then
    RUNTIME_IS_SERVER=1
fi
ctx_set RUNTIME_IS_SERVER "$RUNTIME_IS_SERVER" session

# SSH detection.
RUNTIME_IS_SSH=0
if [ -n "${SSH_CLIENT-}" ] || [ -n "${SSH_TTY-}" ]; then
    RUNTIME_IS_SSH=1
fi
ctx_set RUNTIME_IS_SSH "$RUNTIME_IS_SSH" session

# Offline detection (lazy, 1s timeout on first call).
_runtime_resolve_offline() {
    RUNTIME_IS_OFFLINE=0
    if ! command -v ping >/dev/null 2>&1 || \
       ! ping -c1 -W1 1.1.1.1 >/dev/null 2>&1; then
        RUNTIME_IS_OFFLINE=1
    fi
    export RUNTIME_IS_OFFLINE
}
ctx_set_lazy RUNTIME_IS_OFFLINE _runtime_resolve_offline session

runtime_is_offline() {
    registry_resolve CTX RUNTIME_IS_OFFLINE
    [ "$RUNTIME_IS_OFFLINE" -eq 1 ]
}

# Show all context variables.
runtime_context() {
    local _scope=""
    local _resolve=0
    while [ $# -gt 0 ]; do
        case "$1" in
            --scope) _scope="$2"; shift 2 ;;
            --resolve) _resolve=1; shift ;;
            *) shift ;;
        esac
    done
    if [ -n "$_scope" ]; then
        if [ "$_resolve" = "1" ]; then
            registry_dump CTX --tag "$_scope" --resolve
        else
            registry_dump CTX --tag "$_scope"
        fi
    elif [ "$_resolve" = "1" ]; then
        registry_dump CTX --resolve
    else
        registry_dump CTX --resolve
    fi
}
