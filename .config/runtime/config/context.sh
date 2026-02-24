# Context-derived environment exports.

case "${RUNTIME_OS-}" in
    mac) export CLI_OPEN_CMD="open" ;;
    linux) export CLI_OPEN_CMD="xdg-open" ;;
esac

if [ "${RUNTIME_DISTRO-}" = "arch" ]; then
    export CLI_PKG_MGR="pacman"
fi
