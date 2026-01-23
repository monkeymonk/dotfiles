# defaults/editor.sh

# Prefer vim over nvim on remote SSH sessions.
if [ -n "${SSH_CONNECTION-}" ]; then
  export EDITOR=vim
  export VISUAL=vim
  export SUDO_EDITOR=vim
else
  export EDITOR=nvim
  export VISUAL=nvim
  export SUDO_EDITOR=nvim
fi
