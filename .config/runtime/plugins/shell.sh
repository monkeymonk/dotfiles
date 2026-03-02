# Shell-specific interactive configuration (single file).

runtime_plugin_shell() {
    case ${-:-} in
        *i*) ;;
        *) return 0 ;;
    esac

    case "${SHELL_FAMILY-}" in
        zsh)
            # History
            setopt HIST_IGNORE_DUPS
            setopt HIST_IGNORE_SPACE
            setopt HIST_REDUCE_BLANKS
            setopt SHARE_HISTORY
            HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"

            # Directory navigation
            setopt AUTO_CD
            setopt AUTO_PUSHD
            setopt PUSHD_IGNORE_DUPS
            setopt PUSHD_SILENT

            # Completion
            setopt COMPLETE_IN_WORD
            setopt ALWAYS_TO_END

            # Globbing
            setopt EXTENDED_GLOB
            setopt NO_CASE_GLOB

            # Safety
            setopt NO_CLOBBER
            setopt NO_BEEP

            ;;

        bash)
            # History
            HISTCONTROL=ignoreboth
            shopt -s histappend
            HISTSIZE=1000
            HISTFILESIZE=2000
            HISTORY_IGNORE='(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)'

            shopt -s checkwinsize

            # Lesspipe
            [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

            # Completion
            if ! shopt -oq posix; then
                if [ -f /usr/share/bash-completion/bash_completion ]; then
                    . /usr/share/bash-completion/bash_completion
                elif [ -f /etc/bash_completion ]; then
                    . /etc/bash_completion
                fi
            fi

            ;;
    esac
}

hook_register interactive runtime_plugin_shell
