# shells/zsh/init.zsh

[[ -n "${ZSH_VERSION-}" ]] || return 0

# Interactive shell guard
case $- in
  *i*) ;;
  *) return 0 ;;
esac

autoload -Uz add-zsh-hook 2>/dev/null || true

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
    cli_print_error "Couldn't go up $limit dirs."
    return 1
  fi

  cli_cd "$d"
}

alias cd='cli_cd'
alias up='cli_up'
alias ..='cli_up 2'
alias ...='cli_up 3'
alias ....='cli_up 4'

# Prefer htop / batcat when present
if command -v htop >/dev/null 2>&1; then
  alias oldtop='/usr/bin/top'
  alias top='htop'
fi

if command -v batcat >/dev/null 2>&1; then
  alias oldcat='/usr/bin/cat'
  alias bat='batcat'
  alias cat='batcat'
fi

# starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# fzf
if [ -f "$HOME/.fzf.zsh" ]; then
  source "$HOME/.fzf.zsh"
fi

# "global" venv (preserve prior behavior)
if [ -f "$HOME/venv/bin/activate" ]; then
  source "$HOME/venv/bin/activate"
fi

# pyenv (zsh init)
if [ -d "$PYENV_ROOT" ] && command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# nvm + .nvmrc auto-load (optional)
if [ -n "${NVM_DIR-}" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh"

  if [ -f "$HOME/.config/cli/bin/load-nvmrc.zsh" ]; then
    source "$HOME/.config/cli/bin/load-nvmrc.zsh"
    add-zsh-hook chpwd load-nvmrc
    load-nvmrc
  fi
fi

# tmux autostart (preserve previous behavior)
if command -v tmux >/dev/null 2>&1; then
  if [ -z "${TMUX-}" ]; then
    tmux new-session -A -s Default -c ~
  fi
fi

# zsh-specific helper aliases
alias zshrc="${EDITOR} ~/.zshrc"
alias ohmyzsh="${EDITOR} ~/.oh-my-zsh"

reload() {
  # Reload zsh config and re-run the CLI bootstrap.
  source "$HOME/.zshrc"
  source "$CLI_HOME/start.sh"
  echo "ZSH config reloaded"
}

# compat: source any remaining legacy zsh snippets
for f in "$HOME/.config/shell/zsh"/*.zsh; do
  [[ -e "$f" ]] || continue
  source "$f"
done

# nvim config switcher (zsh-only)
run_nvims() {
  local -a items
  items=(default kickstart LazyVim NvChad)
  local config
  config=$(printf '%s\n' "${items[@]}" | fzf --prompt='nvim config > ' --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo 'Nothing selected'
    return 0
  elif [[ $config == default ]]; then
    config=''
  fi
  NVIM_APPNAME=$config nvim "$@"
}
alias nvims='run_nvims'
alias nchad='NVIM_APPNAME=NvChad nvim'
alias nkick='NVIM_APPNAME=kickstart nvim'
alias nlazy='NVIM_APPNAME=LazyVim nvim'
