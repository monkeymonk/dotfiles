# User preference defaults (no conditionals).

# Example:
# RUNTIME_THEME="default"

TMUX_AUTO_ATTACH="${TMUX_AUTO_ATTACH:-1}"

# User-specific dotfiles helpers (via alx).
if command -v alx >/dev/null 2>&1; then
	if [ -d "$HOME/.dotfiles" ]; then
		alx add dotfiles '/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME' \
			--desc "Manage dotfiles repo" --tags "git"
	fi
	if [ -d "$HOME/.secretfiles" ]; then
		alx add secretfiles '/usr/bin/git --git-dir=$HOME/.secretfiles --work-tree=$HOME' \
			--desc "Manage secretfiles repo" --tags "git"
	fi
fi

alx add lla 'ls -la' --desc "List all (long)" --tags "fs,ls"
alx add llh 'ls -d .*' --desc "List dotfiles" --tags "fs,ls"
alx add llgr 'ls -l | grep' --desc "List (long) and grep" --tags "fs,ls,search"
alx add llagr 'ls -la | grep' --desc "List all (long) and grep" --tags "fs,ls,search"
alx add count 'ls -1 | wc -l' --desc "Count entries" --tags "fs,ls"

alx add grep 'grep --color=auto' --desc "Grep with color" --tags "search,text"
alx add egrep 'egrep --color=auto' --desc "Egrep with color" --tags "search,text"
alx add fgrep 'fgrep --color=auto' --desc "Fgrep with color" --tags "search,text"

alx add cp 'cp -i' --desc "Copy (interactive)" --tags "fs,safe"
alx add ln 'ln -i' --desc "Link (interactive)" --tags "fs,safe"
alx add mv 'mv -i' --desc "Move (interactive)" --tags "fs,safe"
alx add rm 'rm -i' --desc "Remove (interactive)" --tags "fs,safe"

alx add curl 'curl --compressed' --desc "Curl with compression" --tags "net,http"
alx add df 'df -h' --desc "Disk free" --tags "disk,sys"
alx add fu 'du -ch' --desc "Disk usage (du -ch)" --tags "disk"
alx add tfu 'du -sh' --desc "Disk usage summary" --tags "disk"
alx add free 'free -m' --desc "Memory usage" --tags "memory,sys"
alx add usage 'du -ch | grep total' --desc "Disk total usage" --tags "disk"
alx add most 'du -hsx * | sort -rh | head -10' --desc "Largest entries" --tags "disk"

alx add ip 'ip --color=auto' --desc "IP tools (color)" --tags "net"
alx add myip 'curl ipv4.icanhazip.com' --desc "Public IPv4" --tags "net"
alx add diff 'diff --color=auto' --desc "Diff with color" --tags "diff,text"

alx add ping 'ping -c 5' --desc "Ping 5 times" --tags "net"
alx add fastping 'ping -c 100 -s.2' --desc "Ping 100 times" --tags "net"
alx add header 'curl -I' --desc "HTTP headers" --tags "net,http"

alx add ag 'ag -f --hidden' --desc "Ag with hidden" --tags "search"

alx add psa 'ps auxf' --desc "Process tree" --tags "process"
alx add psgrep 'ps aux | grep -v grep | grep -i -e VSZ -e' --desc "Process filter" --tags "process,search"
alx add psmem 'ps auxf | sort -nr -k 4' --desc "Top memory processes" --tags "process,memory"
alx add pscpu 'ps auxf | sort -nr -k 3' --desc "Top CPU processes" --tags "process,cpu"

alx add bye 'exit' --desc "Exit shell" --tags "shell,exit"
alx add :q 'exit' --desc "Exit shell" --tags "shell,exit"
alx add q 'exit' --desc "Exit shell" --tags "shell,exit"
alx add quit 'exit' --desc "Exit shell" --tags "shell,exit"

if [ "$OS" = macos ]; then
	alx add afk 'pmset displaysleepnow' --desc "Sleep display" --tags "sys,power"
elif command -v xdg-screensaver >/dev/null 2>&1; then
	alx add afk 'xdg-screensaver lock' --desc "Lock screen" --tags "sys,lock"
fi
alx add logout 'sudo pkill -u $USER' --desc "Log out user" --tags "sys,admin"
alx add reboot 'sudo reboot' --desc "Reboot system" --tags "sys,admin"
