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
