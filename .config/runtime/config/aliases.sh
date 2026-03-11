# Shell aliases.

if [ -d "$HOME/.dotfiles" ]; then
	alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME' \
		--desc "Manage dotfiles repo" --tags "git"
fi
if [ -d "$HOME/.secretfiles" ]; then
	alias secretfiles='/usr/bin/git --git-dir=$HOME/.secretfiles --work-tree=$HOME' \
		--desc "Manage secretfiles repo" --tags "git"
fi

alias lla='ls -la' --desc "List all (long)" --tags "fs,ls"
alias llh='ls -d .*' --desc "List dotfiles" --tags "fs,ls"
alias llgr='ls -l | grep' --desc "List (long) and grep" --tags "fs,ls,search"
alias llagr='ls -la | grep' --desc "List all (long) and grep" --tags "fs,ls,search"
alias count='ls -1 | wc -l' --desc "Count entries" --tags "fs,ls"
alias c='clear' --desc "Clear screen" --tags "shell,ui"

alias grep='grep --color=auto' --desc "Grep with color" --tags "search,text"
alias egrep='egrep --color=auto' --desc "Egrep with color" --tags "search,text"
alias fgrep='fgrep --color=auto' --desc "Fgrep with color" --tags "search,text"

alias cp='cp -i' --desc "Copy (interactive)" --tags "fs,safe"
alias ln='ln -i' --desc "Link (interactive)" --tags "fs,safe"
alias mv='mv -i' --desc "Move (interactive)" --tags "fs,safe"
alias rm='rm -i' --desc "Remove (interactive)" --tags "fs,safe"

alias curl='curl --compressed' --desc "Curl with compression" --tags "net,http"
alias df='df -h' --desc "Disk free" --tags "disk,sys"
alias fu='du -ch' --desc "Disk usage (du -ch)" --tags "disk"
alias tfu='du -sh' --desc "Disk usage summary" --tags "disk"
alias free='free -m' --desc "Memory usage" --tags "memory,sys"
alias usage='du -ch | grep total' --desc "Disk total usage" --tags "disk"
alias most='du -hsx * | sort -rh | head -10' --desc "Largest entries" --tags "disk"

alias ip='ip --color=auto' --desc "IP tools (color)" --tags "net"
alias myip='curl ipv4.icanhazip.com' --desc "Public IPv4" --tags "net"
alias diff='diff --color=auto' --desc "Diff with color" --tags "diff,text"

alias ping='ping -c 5' --desc "Ping 5 times" --tags "net"
alias fastping='ping -c 100 -s.2' --desc "Ping 100 times" --tags "net"
alias header='curl -I' --desc "HTTP headers" --tags "net,http"

alias ag='ag -f --hidden' --desc "Ag with hidden" --tags "search"

alias psa='ps auxf' --desc "Process tree" --tags "process"
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e' --desc "Process filter" --tags "process,search"
alias psmem='ps auxf | sort -nr -k 4' --desc "Top memory processes" --tags "process,memory"
alias pscpu='ps auxf | sort -nr -k 3' --desc "Top CPU processes" --tags "process,cpu"

alias bye='exit' --desc "Exit shell" --tags "shell,exit"
alias :q='exit' --desc "Exit shell" --tags "shell,exit"
alias q='exit' --desc "Exit shell" --tags "shell,exit"
alias quit='exit' --desc "Exit shell" --tags "shell,exit"

if [ "$RUNTIME_OS" = "mac" ]; then
	alias afk='pmset displaysleepnow' --desc "Sleep display" --tags "sys,power"
elif command -v xdg-screensaver >/dev/null 2>&1; then
	alias afk='xdg-screensaver lock' --desc "Lock screen" --tags "sys,lock"
fi
alias logout='sudo pkill -u $USER' --desc "Log out user" --tags "sys,admin"
alias reboot='sudo reboot' --desc "Reboot system" --tags "sys,admin"
