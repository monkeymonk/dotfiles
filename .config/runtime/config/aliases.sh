# Alias registrations via runtime_alias.

if [ -d "$HOME/.dotfiles" ]; then
	runtime_alias dotfiles '/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME' \
		--desc "Manage dotfiles repo" --tags "git"
fi
if [ -d "$HOME/.secretfiles" ]; then
	runtime_alias secretfiles '/usr/bin/git --git-dir=$HOME/.secretfiles --work-tree=$HOME' \
		--desc "Manage secretfiles repo" --tags "git"
fi

runtime_alias lla 'ls -la' --desc "List all (long)" --tags "fs,ls"
runtime_alias llh 'ls -d .*' --desc "List dotfiles" --tags "fs,ls"
runtime_alias llgr 'ls -l | grep' --desc "List (long) and grep" --tags "fs,ls,search"
runtime_alias llagr 'ls -la | grep' --desc "List all (long) and grep" --tags "fs,ls,search"
runtime_alias count 'ls -1 | wc -l' --desc "Count entries" --tags "fs,ls"
runtime_alias c 'clear' --desc "Clear screen" --tags "shell,ui"

runtime_alias grep 'grep --color=auto' --desc "Grep with color" --tags "search,text"
runtime_alias egrep 'egrep --color=auto' --desc "Egrep with color" --tags "search,text"
runtime_alias fgrep 'fgrep --color=auto' --desc "Fgrep with color" --tags "search,text"

runtime_alias cp 'cp -i' --desc "Copy (interactive)" --tags "fs,safe"
runtime_alias ln 'ln -i' --desc "Link (interactive)" --tags "fs,safe"
runtime_alias mv 'mv -i' --desc "Move (interactive)" --tags "fs,safe"
runtime_alias rm 'rm -i' --desc "Remove (interactive)" --tags "fs,safe"

runtime_alias curl 'curl --compressed' --desc "Curl with compression" --tags "net,http"
runtime_alias df 'df -h' --desc "Disk free" --tags "disk,sys"
runtime_alias fu 'du -ch' --desc "Disk usage (du -ch)" --tags "disk"
runtime_alias tfu 'du -sh' --desc "Disk usage summary" --tags "disk"
runtime_alias free 'free -m' --desc "Memory usage" --tags "memory,sys"
runtime_alias usage 'du -ch | grep total' --desc "Disk total usage" --tags "disk"
runtime_alias most 'du -hsx * | sort -rh | head -10' --desc "Largest entries" --tags "disk"

runtime_alias ip 'ip --color=auto' --desc "IP tools (color)" --tags "net"
runtime_alias myip 'curl ipv4.icanhazip.com' --desc "Public IPv4" --tags "net"
runtime_alias diff 'diff --color=auto' --desc "Diff with color" --tags "diff,text"

runtime_alias ping 'ping -c 5' --desc "Ping 5 times" --tags "net"
runtime_alias fastping 'ping -c 100 -s.2' --desc "Ping 100 times" --tags "net"
runtime_alias header 'curl -I' --desc "HTTP headers" --tags "net,http"

runtime_alias ag 'ag -f --hidden' --desc "Ag with hidden" --tags "search"

runtime_alias psa 'ps auxf' --desc "Process tree" --tags "process"
runtime_alias psgrep 'ps aux | grep -v grep | grep -i -e VSZ -e' --desc "Process filter" --tags "process,search"
runtime_alias psmem 'ps auxf | sort -nr -k 4' --desc "Top memory processes" --tags "process,memory"
runtime_alias pscpu 'ps auxf | sort -nr -k 3' --desc "Top CPU processes" --tags "process,cpu"

runtime_alias bye 'exit' --desc "Exit shell" --tags "shell,exit"
runtime_alias :q 'exit' --desc "Exit shell" --tags "shell,exit"
runtime_alias q 'exit' --desc "Exit shell" --tags "shell,exit"
runtime_alias quit 'exit' --desc "Exit shell" --tags "shell,exit"

if [ "$RUNTIME_OS" = "mac" ]; then
	runtime_alias afk 'pmset displaysleepnow' --desc "Sleep display" --tags "sys,power"
elif command -v xdg-screensaver >/dev/null 2>&1; then
	runtime_alias afk 'xdg-screensaver lock' --desc "Lock screen" --tags "sys,lock"
fi
runtime_alias logout 'sudo pkill -u $USER' --desc "Log out user" --tags "sys,admin"
runtime_alias reboot 'sudo reboot' --desc "Reboot system" --tags "sys,admin"
