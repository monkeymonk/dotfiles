# lib/fs.sh

cli_mkdirp() {
  [ -n "${1-}" ] || return 0
  [ -d "$1" ] || mkdir -p "$1"
}
