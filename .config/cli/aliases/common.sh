# aliases/common.sh

alias c='clear'
alias ls='ls --color=auto'
alias ll='ls -l'
alias lla='ls -la'
alias llh='ls -d .*'
alias llgr='ls -l | grep'
alias llagr='ls -la | grep'
alias path='printf "%s\n" "$PATH" | tr ":" "\n"'
alias cx='chmod +x'
alias count='ls -1 | wc -l'

alias home='cd ~'

alias please='sudo -'
alias root='sudo -i'
alias su='sudo -i'
alias sudo='sudo -i'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias cp='cp -i'
alias ln='ln -i'
alias mv='mv -i'
alias rm='rm -i'

alias curl='curl --compressed'
alias df='df -h'
alias fu='du -ch'
alias tfu='du -sh'
alias free='free -m'
alias usage='du -ch | grep total'
alias most='du -hsx * | sort -rh | head -10'

alias ip='ip --color=auto'
alias myip='curl ipv4.icanhazip.com'
alias diff='diff --color=auto'

alias ping='ping -c 5'
alias fastping='ping -c 100 -s.2'
alias header='curl -I'

alias recent='cli_recent'
alias aliases='cli_aliases'

alias ag='ag -f --hidden'

alias psa='ps auxf'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

alias bye='exit'
alias :q='exit'
alias q='exit'
alias quit='exit'

alias afk='xdg-screensaver lock'
alias logout='sudo pkill -u $USER'
alias reboot='sudo reboot'
