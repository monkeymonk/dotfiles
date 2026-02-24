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
