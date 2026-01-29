# shellcheck shell=sh

# Bootstrap: environment detection and PATH setup.
# Sourced by start.sh before anything else.

# --- OS / Host Detection ---

_cli_uname_s=$(uname -s 2>/dev/null || printf '%s' unknown)

case "$_cli_uname_s" in
  Darwin) OS=macos ;;
  Linux) OS=linux ;;
  *) OS=unknown ;;
esac

HOST=$(hostname -s 2>/dev/null || hostname 2>/dev/null || printf '%s' unknown)

# Best-effort distro detection (Linux only)
DISTRO=
if [ "$OS" = linux ] && [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  DISTRO=${ID-}
fi

# Capabilities (best-effort)
HAS_OLLAMA=0
if command -v ollama >/dev/null 2>&1; then
  HAS_OLLAMA=1
fi

export OS DISTRO HOST HAS_OLLAMA

unset _cli_uname_s

# --- Shell Detection ---

if [ -n "${ZSH_VERSION-}" ]; then
  SHELL_FAMILY=zsh
elif [ -n "${BASH_VERSION-}" ]; then
  SHELL_FAMILY=bash
else
  SHELL_FAMILY=sh
fi

export SHELL_FAMILY

# --- PATH Setup ---

cli_path_prepend() {
  [ -n "${1-}" ] || return 0
  [ -d "$1" ] || return 0

  case ":$PATH:" in
    *":$1:"*) return 0 ;;
  esac

  PATH="$1:$PATH"
}

cli_path_prepend "/bin"
cli_path_prepend "/usr/local/bin"
cli_path_prepend "$HOME/.local/bin"
cli_path_prepend "$HOME/bin"
cli_path_prepend "$CLI_HOME/bin"
cli_path_prepend "/snap/bin"

# Cargo
if [ -f "$HOME/.cargo/env" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.cargo/env"
fi
cli_path_prepend "$HOME/.cargo/bin"

# GHCup
if [ -f "$HOME/.ghcup/env" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.ghcup/env"
fi
cli_path_prepend "$HOME/.ghcup/bin"

# Go
if command -v go >/dev/null 2>&1; then
  _cli_gopath=$(go env GOPATH 2>/dev/null || true)
  if [ -n "$_cli_gopath" ]; then
    cli_path_prepend "$_cli_gopath/bin"
  fi
  unset _cli_gopath
fi

# Composer (PHP)
cli_path_prepend "$HOME/.config/composer/vendor/bin"

# Deno
cli_path_prepend "$HOME/.deno/bin"

# pnpm
cli_path_prepend "$HOME/.local/share/pnpm"

# OpenCode
cli_path_prepend "$HOME/.opencode/bin"

# pyenv (PATH only; shell init happens in shells/<shell>/)
cli_path_prepend "$HOME/.pyenv/bin"

# Bun
cli_path_prepend "$HOME/.bun/bin"

export PATH
