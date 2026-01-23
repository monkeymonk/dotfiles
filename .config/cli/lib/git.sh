# lib/git.sh

cli_git_root() {
  git rev-parse --show-toplevel 2>/dev/null
}
