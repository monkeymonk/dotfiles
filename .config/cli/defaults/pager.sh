# defaults/pager.sh

export PAGER=less
export LESS='-R'

if command -v nvim >/dev/null 2>&1; then
  export MANPAGER='nvim +Man!'
fi
