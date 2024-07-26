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

# Navigation Aliases
function run_cd() {
	builtin cd "$@"
	ls -Fa
}

# Shortcuts for navigation
alias cd="run_cd"
alias home="cd ~"

function run_project() {
	local projects=""
	local selected_project=""
	local project_name=""

	if [ -z "$1" ]; then
		# No project name provided, list all projects and use fzf to select
		projects=$(for dir in "${PROJECTS_BASE_DIRS[@]}"; do
			find "$dir" -maxdepth 1 -type d
		done | fzf --prompt="Projects > " --height=~50% --layout=reverse --border --exit-0)

		# If no project is selected, do nothing
		[[ -z $projects ]] && echo "No project selected" && return
	else
		project_name="$1"

		# Find the given project in the projects list
		projects=$(for dir in "${PROJECTS_BASE_DIRS[@]}"; do
			find "$dir" -maxdepth 1 -type d -iname "*$project_name*"
		done)

		# If no project matching the name is found, inform the user
		if [ -z "$projects" ]; then
			echo "No project found matching '$project_name'"
			return
		fi

		# If multiple projects found, let the user choose one using fzf
		if echo "$projects" | grep -q "$project_name"; then
			selected_project=$(echo "$projects" | fzf --prompt="Select Project > " --height=~50% --layout=reverse --border)

			# Select a project or exit if none selected
			[[ -z $selected_project ]] && return

			projects="$selected_project"
		fi
	fi

	# Change directory to the selected project
	run_cd "$projects" || return

	# Start Neovim and load the last session using persistence.nvim
	nvim -c "lua require('persistence').load()"
}
alias project="run_project"

function run_wk() {
	if [ -z "$1" ]; then
		run_cd "$HOME/works"
	else
		target="$HOME/works/$1"

		if [ ! -d "$target" ]; then
			print_red "Couldn't find directory: $target 😞"
		else
			run_cd "$target"
		fi
	fi
}
alias wk="run_wk"

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
alias root="sudo -i"
alias su="sudo -i"

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
alias df="df -h" # human-readable sizes
alias du="du -ch"
alias free="free -m"
alias usage="du -ch | grep total"
alias most="du -hsx * | sort -rh | head -10"
alias ip="ip --color=auto"
alias diff="diff --color=auto"
alias ssh="TERM=xterm-256color ssh"

# Ping Aliases
alias ping="ping -c 5"
alias fastping="ping -c 100 -s.2"
alias header="curl -I"

# Silver Searcher Alias
alias ag="ag -f --hidden"

# Process Viewing Aliases
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem="ps auxf | sort -nr -k 4"
alias pscpu="ps auxf | sort -nr -k 3"

# Exit Aliases
alias :q="exit"
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

# Screen Locking and User Actions
alias afk="xdg-screensaver lock"
alias logout="sudo pkill -u $USER"
alias reboot="sudo reboot"

# Neovim Aliases
alias vim="nvim"
alias vi="nvim"
alias v="nvim"

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

# Open Dotfiles Configuration
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias dotconfig="cd ~ && nvim"
alias binconfig="cd ~/.local/bin && nvim"
alias shellconfig="cd ~/.config/shell && nvim"
alias vimconfig="cd ~/.config/nvim && nvim"

# Additional Zsh Specific Aliases
if command -v zsh &>/dev/null; then
	alias zshconfig="nvim ~/.zshrc"
	alias ohmyzsh="nvim ~/.oh-my-zsh"
	alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
fi
