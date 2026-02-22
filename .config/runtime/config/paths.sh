# Base PATH entries (deterministic, idempotent).

path_prepend "/bin"
path_prepend "/usr/bin"
path_prepend "/usr/local/bin"
path_prepend "/usr/local/sbin"
path_prepend "/usr/sbin"
path_prepend "/sbin"

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# System package managers / platforms
if [ -d "/snap/bin" ] && command -v snap >/dev/null 2>&1; then
    path_prepend "/snap/bin"
fi
if [ -d "/opt/homebrew/bin" ]; then
    path_prepend "/opt/homebrew/bin"
fi
if [ -d "/opt/homebrew/sbin" ]; then
    path_prepend "/opt/homebrew/sbin"
fi
if [ -d "/opt/local/bin" ]; then
    path_prepend "/opt/local/bin"
fi
if [ -d "/opt/local/sbin" ]; then
    path_prepend "/opt/local/sbin"
fi
