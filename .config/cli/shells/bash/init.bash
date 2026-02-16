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
HISTORY_IGNORE='(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)'

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
  local start_time=$(date +%s%N)
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi

  if [ -f "$CLI_HOME/start.sh" ]; then
    . "$CLI_HOME/start.sh"
  fi

  local end_time=$(date +%s%N)
  local elapsed=$(( (end_time - start_time) / 1000000 ))
  echo "Bash config reloaded in ${elapsed}ms"
}

# pyenv lazy loading (loads on first use)
if [ -d "${PYENV_ROOT:-$HOME/.pyenv}" ] && command -v pyenv >/dev/null 2>&1; then
  _lazy_load_pyenv() {
    unset -f pyenv python python3 pip pip3 _lazy_load_pyenv 2>/dev/null
    eval "$(command pyenv init --path)"
    eval "$(command pyenv init -)"
  }

  pyenv() { _lazy_load_pyenv; command pyenv "$@"; }
  python() { _lazy_load_pyenv; command python "$@"; }
  python3() { _lazy_load_pyenv; command python3 "$@"; }
  pip() { _lazy_load_pyenv; command pip "$@"; }
  pip3() { _lazy_load_pyenv; command pip3 "$@"; }
fi

# nvm lazy loading (loads on first use)
if [ -n "${NVM_DIR-}" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
  _lazy_load_nvm() {
    unset -f nvm node npm npx _lazy_load_nvm 2>/dev/null
    . "$NVM_DIR/nvm.sh"

    if [ -f "$HOME/.config/cli/bin/cdnvm.sh" ]; then
      . "$HOME/.config/cli/bin/cdnvm.sh"
      alias cd='cdnvm'
      cdnvm "$PWD" || true
    fi
  }

  nvm() { _lazy_load_nvm; nvm "$@"; }
  node() { _lazy_load_nvm; node "$@"; }
  npm() { _lazy_load_nvm; npm "$@"; }
  npx() { _lazy_load_nvm; npx "$@"; }
fi
