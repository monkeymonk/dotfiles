# lib/interactive.sh — shared interactive-shell code
# Sourced in interactive shells only (from start.sh)
# Depends: lib/ux.sh (cli_print_error — with fallback)

# Guard: skip if not interactive (lib/ glob also sources this)
case ${-:-} in *i*) ;; *) return 0 ;; esac

# --- Navigation ---

cli_cd() {
  builtin cd "$@" || return
  ls -Fa
}

cli_up() {
  limit=${1:-1}
  d=
  i=0
  while [ "$i" -lt "$limit" ]; do
    d="../$d"
    i=$((i + 1))
  done

  if [ ! -d "$d" ]; then
    if command -v cli_print_error >/dev/null 2>&1; then
      cli_print_error "Couldn't go up $limit dirs."
    else
      printf '%s\n' "Couldn't go up $limit dirs." >&2
    fi
    return 1
  fi

  cli_cd "$d"
}

alias cd='cli_cd'
alias up='cli_up'
alias ..='cli_up 2'
alias ...='cli_up 3'
alias ....='cli_up 4'

# --- Tool preferences ---

if command -v htop >/dev/null 2>&1; then
  alias oldtop='/usr/bin/top'
  alias top='htop'
fi

if command -v batcat >/dev/null 2>&1; then
  alias oldcat='/usr/bin/cat'
  alias bat='batcat'
  alias cat='batcat'
fi

# --- Prompt ---

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init "${SHELL_FAMILY:-sh}")"
fi

# --- FZF ---

# shellcheck disable=SC1090
[ -f "$HOME/.fzf.${SHELL_FAMILY}" ] && . "$HOME/.fzf.${SHELL_FAMILY}"

# --- Python venv ---

# shellcheck disable=SC1091
[ -f "$HOME/venv/bin/activate" ] && . "$HOME/venv/bin/activate"

# --- Tmux ---

if command -v tmux >/dev/null 2>&1; then
  if [ -n "${TMUX_AUTO_ATTACH-}" ] && [ -z "${TMUX-}" ]; then
    tmux new-session -A -s Default -c ~
  fi
fi
