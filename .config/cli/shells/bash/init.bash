# shells/bash/init.bash

# Interactive guard
case $- in
  *i*) ;;
  *) return 0 ;;
esac

# History
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s checkwinsize

# Lesspipe
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

reload() {
  # If your ~/.bashrc sources the CLI bootstrap, this reloads everything.
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi

  if [ -f "$CLI_HOME/start.sh" ]; then
    . "$CLI_HOME/start.sh"
  fi

  echo "Bash config reloaded"
}

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
    command -v cli_print_error >/dev/null 2>&1 && cli_print_error "Couldn't go up $limit dirs." || echo "Couldn't go up $limit dirs." >&2
    return 1
  fi

  cli_cd "$d"
}

# starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# fzf
if [ -f "$HOME/.fzf.bash" ]; then
  . "$HOME/.fzf.bash"
fi

# "global" venv (preserve prior behavior)
if [ -f "$HOME/venv/bin/activate" ]; then
  . "$HOME/venv/bin/activate"
fi

# pyenv (bash init)
if [ -d "${PYENV_ROOT:-$HOME/.pyenv}" ] && command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

alias cd='cli_cd'
alias up='cli_up'
alias ..='cli_up 2'
alias ...='cli_up 3'
alias ....='cli_up 4'

# nvm (optional)
if [ -n "${NVM_DIR-}" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"

  if [ -f "$HOME/.config/cli/bin/cdnvm.sh" ]; then
    . "$HOME/.config/cli/bin/cdnvm.sh"
    alias cd='cdnvm'
    cdnvm "$PWD" || return 0
  fi
fi

# tmux autostart
if command -v tmux >/dev/null 2>&1; then
  if [ -z "${TMUX-}" ]; then
    tmux new-session -A -s Default -c ~
  fi
fi
