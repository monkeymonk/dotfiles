#!/bin/bash
#    _______   ____ ___
#   ╱       ╲╲╱    ╱   ╲
#  ╱        ╱╱         ╱    Monkey Monk
# ╱         ╱╱       _╱     http://monkeymonk.be
# ╲__╱__╱__╱╲╲___╱___╱
#
# env.sh

# Set PATH variable
PATH=/bin:$PATH

# Add user bin
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# Add local bin
if [ -d "/usr/local/bin" ]; then
  PATH="/usr/local/bin:$PATH"
fi

# Add snap bin
if [ -d "/snap/bin" ]; then
  PATH="/snap/bin:$PATH"
fi

# Add cargo bin
if [ -d "$HOME/.cargo/bin" ]; then
  if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
  fi

  PATH="$HOME/.cargo/bin:$PATH"
fi

# Add haskell
if [ -d "$HOME/.ghcup/bin" ]; then
  if [ -f "$HOME/.ghcup/env" ]; then
    . "$HOME/.ghcup/env"
  fi

  PATH="$HOME/.ghcup/bin:$PATH"
fi

# Add composer bin
if [ -d "$HOME/.config/composer/vendor/bin" ]; then
  PATH="$HOME/.config/composer/vendor/bin:$PATH"
fi

# Add deno
if [ -d "$HOME/.deno/bin" ]; then
  PATH="$HOME/.deno/bin:$PATH"
fi

# Add pyenv if installed
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# Get the current directory and look for a virtual environment in it
if [ -f "$HOME/venv/bin/activate" ]; then
  . "$HOME/venv/bin/activate"
fi

# Add nvm if installed
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
fi

# Add local bin
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

# Add custon shell bin
if [ -d "$HOME/.config/shell/bin" ]; then
  PATH="$HOME/.config/shell/bin:$PATH"
fi

# see ~/.aws/mfa.sh
if [ -f "$HOME/.aws/.mfa_session" ]; then
  . "$HOME/.aws/.mfa_session"
fi

export PATH
