# shells/zsh/init.zsh

[[ -n "${ZSH_VERSION-}" ]] || return 0

# Interactive shell guard
case $- in
  *i*) ;;
  *) return 0 ;;
esac

autoload -Uz add-zsh-hook 2>/dev/null || true

# Bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# pyenv lazy loading (loads on first use)
if [ -d "$PYENV_ROOT" ] && command -v pyenv >/dev/null 2>&1; then
  # Disable Oh My Zsh aliases that conflict with our function wrappers
  disable -a pyenv python python3 pip pip3 2>/dev/null

  # Helper to clean up and init pyenv
  _lazy_load_pyenv() {
    unfunction pyenv python python3 pip pip3 _lazy_load_pyenv 2>/dev/null
    eval "$(command pyenv init --path)"
    eval "$(command pyenv init -)"
  }

  # Lazy-load wrappers
  function pyenv() {
    _lazy_load_pyenv
    pyenv "$@"
  }

  function python() {
    _lazy_load_pyenv
    python "$@"
  }

  function python3() {
    _lazy_load_pyenv
    python3 "$@"
  }

  function pip() {
    _lazy_load_pyenv
    pip "$@"
  }

  function pip3() {
    _lazy_load_pyenv
    pip3 "$@"
  }
fi

# nvm lazy loading (loads on first use)
if [ -n "${NVM_DIR-}" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
  # Disable Oh My Zsh aliases that conflict with our function wrappers
  disable -a nvm node npm npx 2>/dev/null

  # Helper to clean up and init nvm
  _lazy_load_nvm() {
    unfunction nvm node npm npx _lazy_load_nvm 2>/dev/null
    source "$NVM_DIR/nvm.sh"

    # Load .nvmrc auto-switching after nvm is loaded
    if [ -f "$HOME/.config/cli/bin/load-nvmrc.zsh" ]; then
      source "$HOME/.config/cli/bin/load-nvmrc.zsh"
      add-zsh-hook chpwd load-nvmrc
      load-nvmrc
    fi
  }

  # Lazy-load wrappers
  function nvm() {
    _lazy_load_nvm
    nvm "$@"
  }

  function node() {
    _lazy_load_nvm
    node "$@"
  }

  function npm() {
    _lazy_load_nvm
    npm "$@"
  }

  function npx() {
    _lazy_load_nvm
    npx "$@"
  }
fi

# zsh-specific helper aliases
alias zshrc="${EDITOR} ~/.zshrc"
alias ohmyzsh="${EDITOR} ~/.oh-my-zsh"

reload() {
  # Reload zsh config and re-run the CLI bootstrap.
  local start_time=$(date +%s%N)
  source "$HOME/.zshrc"
  source "$CLI_HOME/start.sh"
  local end_time=$(date +%s%N)
  local elapsed=$(( (end_time - start_time) / 1000000 ))
  echo "ZSH config reloaded in ${elapsed}ms"
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
