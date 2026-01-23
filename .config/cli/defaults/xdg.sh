# defaults/xdg.sh

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"

export XDG_CONFIG_HOME
export XDG_DATA_HOME
export XDG_CACHE_HOME
