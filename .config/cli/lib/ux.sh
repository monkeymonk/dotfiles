# lib/ux.sh

cli_print_ok() {
  printf '\033[0;32m%s\033[0m\n' "$*"
}

cli_print_warn() {
  printf '\033[0;33m%s\033[0m\n' "$*" >&2
}

cli_print_error() {
  printf '\033[0;31m%s\033[0m\n' "$*" >&2
}
