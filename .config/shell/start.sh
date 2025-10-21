#!/bin/bash
#    _______   ____ ___
#   ╱       ╲╲╱    ╱   ╲
#  ╱        ╱╱         ╱    Monkey Monk
# ╱         ╱╱       _╱     http://monkeymonk.be
# ╲__╱__╱__╱╲╲___╱___╱
#
# start.sh

# Set locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

if [ -f "$HOME/.config/shell/secrets.sh" ]; then
  . "$HOME/.config/shell/secrets.sh"
fi

. "$HOME/.config/shell/env.sh"
. "$HOME/.config/shell/aliases.sh"

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # If not running interactively, don't do anything
  case $- in
  *i*) ;;
  *) return ;;
  esac

  # don't put duplicate lines or lines starting with space in the history.
  # See bash(1) for more options
  HISTCONTROL=ignoreboth

  # append to the history file, don't overwrite it
  shopt -s histappend

  # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
  HISTSIZE=1000
  HISTFILESIZE=2000

  # check the window size after each command and, if necessary,
  # update the values of LINES and COLUMNS.
  shopt -s checkwinsize

  # If set, the pattern "**" used in a pathname expansion context will
  # match all files and zero or more directories and subdirectories.
  #shopt -s globstar

  # make less more friendly for non-text input files, see lesspipe(1)
  [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

  # enable programmable completion features (you don't need to enable
  # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
  # sources /etc/bash.bashrc).
  if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi
  fi

  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi

  # starship
  if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
  fi

  if [ -f ~/.fzf.bash ]; then
    . "$HOME/.fzf.bash"
  fi
fi

# Check if tmux is installed
if command -v tmux >/dev/null 2>&1; then
  # Start tmux if it's not already running
  if [ -z "$TMUX" ]; then
    tmux
  fi
fi

# Check if nvm is installed
if command -v nvm &>/dev/null; then
  if [ -n "$BASH_VERSION" ]; then
    . "$HOME/.config/shell/bin/cdnvm.sh"

    alias cd='cdnvm'
    cdnvm "$PWD" || exit
  else
    . "$HOME/.config/shell/bin/load-nvmrc.zsh"

    add-zsh-hook chpwd load-nvmrc
    load-nvmrc
  fi
fi

# Source all zsh-specific snippets only when running zsh
if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz add-zsh-hook 2>/dev/null || true

  # In zsh, enable null_glob so the glob can expand to nothing
  setopt local_options null_glob 2>/dev/null

  for f in "$HOME/.config/shell/zsh"/*.zsh; do
    [ -e "$f" ] || continue # skip if no matches
    . "$f"
  done
fi
