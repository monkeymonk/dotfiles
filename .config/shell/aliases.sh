#!/bin/bash
#    _______   ____ ___
#   ╱       ╲╲╱    ╱   ╲
#  ╱        ╱╱         ╱    Monkey Monk
# ╱         ╱╱       _╱     http://monkeymonk.be
# ╲__╱__╱__╱╲╲___╱___╱
#
# aliases.sh

print_green() {
  local GREEN='\033[0;32m'
  local NC='\033[0m' # No Color
  echo -e "${GREEN}$1${NC}"
}

print_red() {
  local RED='\033[0;31m'
  local NC='\033[0m' # No Color
  echo -e "${RED}$1${NC}"
}

aliases() {
  grep '^alias ' ~/.config/shell/aliases.sh
}

# General Aliases
alias c="clear"
alias ls="ls --color=auto"
alias ll="ls -l"
alias lla="ls -la"
alias llh="ls -d .*"
alias llgr="ls -l | grep"
alias llagr="ls -la | grep"
alias path='echo -e ${PATH//:/\\n}'
alias cx="chmod +x"
alias count="echo $(ls -1 | wc -l)"
alias recent="ls -lt | head -2 | tail -1 | awk '{ print $NF }' | xargs open"

# Navigation Aliases
function run_cd() {
  builtin cd "$@"
  ls -Fa
}

# Shortcuts for navigation
alias cd="run_cd"
alias home="cd ~"
alias wk="project"

# Function to navigate up directories
run_up() {
  local d=""
  local limit="$1"

  # Set limit to 1 if no arguments provided
  [ -z "$limit" ] && limit=1

  for ((i = 1; i <= limit; i++)); do
    d="../$d"
  done

  # Change directory and show error if cd fails
  if [ ! -d "$d" ]; then
    print_red "Couldn't go up $limit dirs."
  else
    run_cd "$d"
  fi
}
alias up="run_up"
alias ..="up 2"
alias ...="up 3"
alias ....="up 4"
alias .4="up 5"
alias .5="up 6"

# Root Access Aliases
alias please="sudo -"
alias root="sudo -i"
alias su="sudo -i"
alias sudo="sudo -i"

# Colorize Outputs
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"

# Confirm before Overwriting
alias cp="cp -i"
alias ln="ln -i"
alias mv="mv -i"
alias rm="rm -i"

# Additional Usability Aliases
alias curl="curl --compressed"
alias df="df -h"   # human-readable sizes
alias du="f"       # disk usage
alias fu="du -ch"  # folder usage
alias tfu="du -sh" # total folder usage
alias free="free -m"
alias usage="du -ch | grep total"
alias most="du -hsx * | sort -rh | head -10"
alias ip="ip --color=auto"
alias diff="diff --color=auto"
# alias ssh="TERM=xterm-kitty ssh"

# Ping Aliases
alias ping="ping -c 5"
alias fastping="ping -c 100 -s.2"
alias header="curl -I"

run_benchurl() {
  # @see https://stackoverflow.com/questions/18215389/how-do-i-measure-request-and-response-times-at-once-using-curl
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
alias benchurl="run_benchurl"

# Silver Searcher Alias
alias ag="ag -f --hidden"

# Process Viewing Aliases
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem="ps auxf | sort -nr -k 4"
alias pscpu="ps auxf | sort -nr -k 3"

# Exit Aliases
alias bye="exit"
alias :q="exit"
alias q="exit"
alias quit="exit"

# Use htop if available
if command -v htop &>/dev/null; then
  alias oldtop="/usr/bin/top"
  alias top="htop"
fi

# Use batcat instead of cat if available
if command -v batcat &>/dev/null; then
  alias oldcat="/usr/bin/cat"
  alias cat="batcat"
fi

# Serve Shortcut for HTTP Server
alias serve="open http://0.0.0.0:8000 && python -m http.server"

# Python alises
alias mkvenv="python3 -m venv venv"
alias activate="source venv/bin/activate"
alias pipupgrade="pip list --outdated | cut -d ' ' -f 1 | xargs pip install --upgrade"

# Screen Locking and User Actions
alias afk="xdg-screensaver lock"
alias logout="sudo pkill -u $USER"
alias reboot="sudo reboot"

# Neovim Aliases
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias vl="nvim +'lua require(\"persistence\").load()'"

run_nvims() {
  items=("default" "kickstart" "LazyVim" "NvChad")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Nvim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}
alias nvims="run_nvims"
alias nchad="NVIM_APPNAME=NvChad nvim"
alias nkick="NVIM_APPNAME=kickstart nvim"
alias nlazy="NVIM_APPNAME=LazyVim nvim"
alias wezterm='flatpak run org.wezfurlong.wezterm'

# Update All Software
run_update() {
  # Update APT package manager (for Ubuntu)
  if command -v apt-get &>/dev/null; then
    sudo apt update -y && sudo apt upgrade -y
  fi

  # Check if yum (for CentOS/RHEL) package manager is available
  if command -v yum &>/dev/null; then
    sudo yum update -y
  fi

  # Check if pacman (for Arch Linux) package manager is available
  if command -v pacman &>/dev/null; then
    sudo pacman -Syu --noconfirm
  fi

  # Check if npm is installed
  if command -v npm &>/dev/null; then
    npm cache clean && npm i -g && npm update -g
  fi

  # Check if Composer is installed
  if command -v composer &>/dev/null; then
    composer global update
  fi

  # Check if Python is installed
  if command -v python &>/dev/null; then
    python -m pip install --user --upgrade pip
    python -m pip list --outdated --format=legacy | awk '{ print $1 }' | xargs -n1 pip install -U
  fi

  # Check if Snap is installed
  if command -v snap &>/dev/null; then
    sudo snap refresh
  fi

  # Check if Cargo is installed
  if command -v cargo &>/dev/null; then
    if ! command -v cargo-update &>/dev/null; then
      cargo install cargo-update
    fi
    cargo install-update -a
  fi

  # Update Oh My Zsh (if installed)
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo ""
    print_green "Updating Oh My Zsh..."
    omz update
  fi

  # Update Tmux plugins with Tmux Plugin Manager (if installed)
  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo ""
    print_green "Updating Tmux plugins with Tmux Plugin Manager..."

    # Update Tmux plugins
    $HOME/.tmux/plugins/tpm/bin/update_plugins all
  fi

  echo ""
  print_green " ( Everything is up to date! )>    ᕙ(⇀‸↼‶)ᕗ "
}
alias update="run_update"

alias wth="curl -s 'wttr.in/?format=3'"

# Set Preferred Editor for Sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR=vim
  export VISUAL=vim
else
  export EDITOR=nvim
  export VISUAL=nvim
fi

# Configure fzf to use fd by default (fd respects .gitignore defaults)
export FZF_DEFAULT_COMMAND="fd --type f"

# Manage dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias secretfiles="/usr/bin/git --git-dir=$HOME/.secretfiles --work-tree=$HOME"

# Open Dotfiles Configuration
alias bashrc="${EDITOR} ~/.bashrc"
alias dotconfig="cd ~ && ${EDITOR}"
alias binconfig="cd ~/.local/bin && ${EDITOR}"
alias shellconfig="cd ~/.config/shell && ${EDITOR}"
alias vimconfig="cd ~/.config/nvim && ${EDITOR}"

# Additional Zsh Specific Aliases
if command -v zsh &>/dev/null; then
  alias zshrc="${EDITOR} ~/.zshrc"
  alias ohmyzsh="${EDITOR} ~/.oh-my-zsh"
  alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
fi
