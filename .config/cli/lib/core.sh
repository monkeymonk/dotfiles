# lib/core.sh

cli_is_interactive() {
  case ${-:-} in
    *i*) return 0 ;;
    *) return 1 ;;
  esac
}

cli_has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

cli_aliases() {
  command grep '^alias ' "$CLI_HOME/aliases"/*.sh 2>/dev/null | \
    sed 's|.*/aliases/||; s|\.sh:alias | |' | \
    sort
}
