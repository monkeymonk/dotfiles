# Neovim integration (with SSH fallback to vim).
# Uses bob (neovim version manager) when available.

_neovim_bob_setup() {
    has_cmd bob || return 1
    local bob_nvim_dir="${HOME}/.local/share/bob/nvim-bin"
    if [ ! -x "${bob_nvim_dir}/nvim" ]; then
        bob install latest 2>/dev/null
        bob use latest 2>/dev/null
    fi
    [ -d "$bob_nvim_dir" ] && path_prepend "$bob_nvim_dir"
}

runtime_plugin_neovim() {
    _neovim_bob_setup
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
