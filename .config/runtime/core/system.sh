# System utilities (no side effects).

is_mac() {
    case "${OSTYPE-}" in
        darwin*) return 0 ;;
    esac
    return 1
}

is_linux() {
    case "${OSTYPE-}" in
        linux*) return 0 ;;
    esac
    return 1
}

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

has_file() {
    [ -f "$1" ]
}

has_dir() {
    [ -d "$1" ]
}

require_cmd() {
    has_cmd "$1"
}
