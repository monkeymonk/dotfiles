# shellcheck shell=sh

# Main entrypoint. Intended to be sourced by shells.
# Canonical load order:
# 1) bootstrap.sh (env detection, shell detection, PATH)
# 2) env/ (base -> os -> host)
# 3) secrets/
# 4) defaults/
# 5) lib/
# 6) aliases/ (interactive only)
# 7) shells/<shell>/ (interactive only)

CLI_HOME="$HOME/.config/cli"
export CLI_HOME

cli_source_if_exists() {
  [ -f "$1" ] || return 0
  # shellcheck disable=SC1090
  . "$1"
}

cli_source_dir() {
  _cli_dir=$1
  _cli_ext=$2
  [ -d "$_cli_dir" ] || return 0

  for _cli_f in "$_cli_dir"/*."${_cli_ext}"; do
    [ -e "$_cli_f" ] || continue
    cli_source_if_exists "$_cli_f"
  done

  unset _cli_dir _cli_ext _cli_f
}

# Bootstrap (env, shell, PATH)
cli_source_if_exists "$CLI_HOME/bootstrap.sh"

# Environment facts
cli_source_if_exists "$CLI_HOME/env/base.env"
cli_source_if_exists "$CLI_HOME/env/dev.env"
cli_source_if_exists "$CLI_HOME/env/os/${OS}.env"

if [ "$OS" = linux ] && [ -n "${DISTRO-}" ]; then
  cli_source_if_exists "$CLI_HOME/env/os/${DISTRO}.env"
fi

if [ -n "${HOST-}" ]; then
  cli_source_if_exists "$CLI_HOME/env/host/${HOST}.env"
fi

# Secrets (optional)
cli_source_if_exists "$CLI_HOME/secrets/secrets.env"

# Defaults
cli_source_dir "$CLI_HOME/defaults" sh

# Library functions
cli_source_dir "$CLI_HOME/lib" sh

# Interactive-only layers
case ${-:-} in
*i*)
  cli_source_dir "$CLI_HOME/aliases" sh
  case "${SHELL_FAMILY-}" in
  zsh) cli_source_dir "$CLI_HOME/shells/zsh" zsh ;;
  bash) cli_source_dir "$CLI_HOME/shells/bash" bash ;;
  fish) cli_source_dir "$CLI_HOME/shells/fish" fish ;;
  *) : ;;
  esac
  ;;
esac

# Clean up bootstrap-only helpers
unset -f cli_source_if_exists cli_source_dir
