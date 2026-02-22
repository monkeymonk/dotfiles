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

            # Clipboard helpers
            clipboard() {
                if [ -n "${WAYLAND_DISPLAY-}" ] && command -v wl-copy >/dev/null 2>&1; then
                    wl-copy
                    return
                fi
                if [ -n "${DISPLAY-}" ]; then
                    if command -v xclip >/dev/null 2>&1; then
                        xclip -selection clipboard
                        return
                    elif command -v xsel >/dev/null 2>&1; then
                        xsel --clipboard --input
                        return
                    fi
                fi
                if command -v pbcopy >/dev/null 2>&1; then
                    pbcopy
                    return
                fi
                if command -v clip.exe >/dev/null 2>&1; then
                    clip.exe
                    return
                fi
                if command -v putclip >/dev/null 2>&1; then
                    putclip
                    return
                fi
                data=$(cat | base64 | tr -d '\r\n')
                printf '\033]52;c;%s\a' "$data"
            }

            clipboard_get() {
                if [ -n "${WAYLAND_DISPLAY-}" ] && command -v wl-paste >/dev/null 2>&1; then
                    wl-paste
                elif [ -n "${DISPLAY-}" ] && command -v xclip >/dev/null 2>&1; then
                    xclip -selection clipboard -o
                elif [ -n "${DISPLAY-}" ] && command -v xsel >/dev/null 2>&1; then
                    xsel --clipboard --output
                elif command -v pbpaste >/dev/null 2>&1; then
                    pbpaste
                elif command -v powershell.exe >/dev/null 2>&1; then
                    powershell.exe Get-Clipboard | tr -d '\r'
                fi
            }

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

runtime_hook_register late runtime_plugin_shell
