# lib/dev.sh

cli_benchurl() {
  # https://stackoverflow.com/questions/18215389/
  curl -so /dev/null -w "
    time_namelookup:  %{time_namelookup}\n\
       time_connect:  %{time_connect}\n\
    time_appconnect:  %{time_appconnect}\n\
   time_pretransfer:  %{time_pretransfer}\n\
      time_redirect:  %{time_redirect}\n\
 time_starttransfer:  %{time_starttransfer}\n\
                     ----------\n\
         time_total:  %{time_total}\n" "$@"
}

cli_update() {
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt update -y && sudo apt upgrade -y
  fi

  if command -v yum >/dev/null 2>&1; then
    sudo yum update -y
  fi

  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -Syu --noconfirm
  fi

  if command -v npm >/dev/null 2>&1; then
    npm cache clean && npm i -g && npm update -g
  fi

  if command -v composer >/dev/null 2>&1; then
    composer global update
  fi

  if command -v rustup >/dev/null 2>&1; then
    rustup update
  fi

  if command -v python >/dev/null 2>&1; then
    python -m pip install --user --upgrade pip
    python -m pip list --outdated --format=legacy | awk '{ print $1 }' | xargs -n1 pip install -U
  fi

  if command -v pyenv >/dev/null 2>&1; then
    pyenv update
  fi

  if command -v snap >/dev/null 2>&1; then
    sudo snap refresh
  fi

  if command -v cargo >/dev/null 2>&1; then
    if ! command -v cargo-update >/dev/null 2>&1; then
      cargo install cargo-update
    fi
    cargo install-update -a
  fi

  if [ -d "$HOME/.oh-my-zsh" ] && command -v omz >/dev/null 2>&1; then
    printf '\n'
    cli_print_ok "Updating Oh My Zsh..."
    omz update
  fi

  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    printf '\n'
    cli_print_ok "Updating Tmux plugins..."
    "$HOME/.tmux/plugins/tpm/bin/update_plugins" all
  fi
}

cli_serve() {
  _cli_port=${1:-8000}
  _cli_url="http://0.0.0.0:${_cli_port}"

  if command -v "${CLI_OPEN_CMD-}" >/dev/null 2>&1; then
    "${CLI_OPEN_CMD}" "$_cli_url" >/dev/null 2>&1 &
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$_cli_url" >/dev/null 2>&1 &
  elif command -v open >/dev/null 2>&1; then
    open "$_cli_url" >/dev/null 2>&1 &
  fi

  if command -v python >/dev/null 2>&1; then
    python -m http.server "$_cli_port"
  else
    python3 -m http.server "$_cli_port"
  fi
}

cli_recent() {
  # Open the most recently modified file in the current directory.
  _cli_recent_file=$(ls -lt | awk 'NR==2 {print $NF}')
  [ -n "${_cli_recent_file-}" ] || return 0

  if [ -n "${CLI_OPEN_CMD-}" ] && command -v "$CLI_OPEN_CMD" >/dev/null 2>&1; then
    "$CLI_OPEN_CMD" "$_cli_recent_file"
    return 0
  fi

  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$_cli_recent_file"
    return 0
  fi

  if command -v open >/dev/null 2>&1; then
    open "$_cli_recent_file"
    return 0
  fi

  return 1
}
