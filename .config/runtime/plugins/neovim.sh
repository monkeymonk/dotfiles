# Neovim integration (with SSH fallback to vim).

runtime_plugin_neovim() {
    require_cmd nvim || return 0

    if [ -n "${SSH_CONNECTION-}" ]; then
        export EDITOR="vim"
        export VISUAL="vim"
        export SUDO_EDITOR="vim"
    else
        export EDITOR="nvim"
        export VISUAL="nvim"
        export SUDO_EDITOR="nvim"
    fi

    export MANPAGER="nvim +Man!"

    runtime_neovim_aliases
}

runtime_neovim_aliases() {
    guard_double_load RUNTIME_NEOVIM_ALIASES_LOADED || return 0
    alias v="nvim" --desc "Neovim editor" --tags "nvim,editor"
    alias vim="nvim" --desc "Neovim editor" --tags "nvim,editor"
    alias vl="nvim +'lua require(\"persistence\").load()'" --desc "Neovim last session" --tags "nvim,editor,session"
}

hook_register setup runtime_plugin_neovim
