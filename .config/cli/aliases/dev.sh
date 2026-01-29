# aliases/dev.sh

alias wk='project'

alias mkvenv='python3 -m venv venv'
alias activate='. venv/bin/activate'
alias pipupgrade='pip list --outdated | cut -d " " -f 1 | xargs pip install --upgrade'

alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias vl="nvim +'lua require(\"persistence\").load()'"

# Config shortcuts
alias bashrc="${EDITOR} ~/.bashrc"
alias dotconfig="cd ~ && ${EDITOR}"
alias binconfig="cd ~/.local/bin && ${EDITOR}"
alias cliconfig="cd ~/.config/cli && ${EDITOR}"
alias vimconfig="cd ~/.config/nvim && ${EDITOR}"

# tmux
alias fux='tmuxp load $(tmuxp ls | fzf --layout=reverse --info=inline --height=40%)'

alias benchurl='cli_benchurl'
alias update='cli_update'
alias serve='cli_serve'

alias wth="curl -s 'wttr.in/?format=3'"
