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

# CI detection.
RUNTIME_IS_CI=0
if [ "${CI-}" = "true" ] || [ -n "${GITHUB_ACTIONS-}" ] || [ -n "${GITLAB_CI-}" ] || \
   [ -n "${TRAVIS-}" ] || [ -n "${CIRCLECI-}" ]; then
    RUNTIME_IS_CI=1
fi

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

# Server detection: Linux with no display server.
RUNTIME_IS_SERVER=0
if [ "$RUNTIME_OS" = "linux" ] && [ -z "${DISPLAY-}" ] && [ -z "${WAYLAND_DISPLAY-}" ]; then
    RUNTIME_IS_SERVER=1
fi

# SSH detection.
RUNTIME_IS_SSH=0
if [ -n "${SSH_CLIENT-}" ] || [ -n "${SSH_TTY-}" ]; then
    RUNTIME_IS_SSH=1
fi
