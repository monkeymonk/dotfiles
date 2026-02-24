# Interactive helpers.

confirm() {
    local _prompt _answer
    _prompt=${1:-"Continue?"}
    [ -t 0 ] || return 1
    printf '%s [y/N]: ' "$_prompt" >&2
    read -r _answer
    case "$_answer" in
        y|Y|yes|YES) return 0 ;;
    esac
    return 1
}

choose_one() {
    local _prompt _choice
    _prompt=$1
    shift
    [ "$#" -gt 0 ] || return 1
    [ -t 0 ] || return 1

    if command -v fzf >/dev/null 2>&1; then
        _choice=$(printf '%s\n' "$@" | fzf --prompt="$_prompt ")
        [ -n "$_choice" ] || return 1
        printf '%s\n' "$_choice"
        return 0
    fi

    printf '%s\n' "$_prompt" >&2
    select _choice in "$@"; do
        [ -n "$_choice" ] || return 1
        printf '%s\n' "$_choice"
        return 0
    done
}

choose_multi() {
    local _prompt _choice _i _opt _n _out _line
    _prompt=$1
    shift
    [ "$#" -gt 0 ] || return 1
    [ -t 0 ] || return 1

    if command -v fzf >/dev/null 2>&1; then
        _choice=$(printf '%s\n' "$@" | fzf -m --prompt="$_prompt ")
        [ -n "$_choice" ] || return 1
        printf '%s\n' "$_choice"
        return 0
    fi

    printf '%s\n' "$_prompt" >&2
    _i=1
    for _opt in "$@"; do
        printf '  %d) %s\n' "$_i" "$_opt" >&2
        _i=$((_i + 1))
    done
    printf 'Enter choices (space-separated numbers): ' >&2
    read -r _line

    _out=""
    for _n in $_line; do
        _i=1
        for _opt in "$@"; do
            if [ "$_i" = "$_n" ]; then
                if [ -n "$_out" ]; then
                    _out="$_out
$_opt"
                else
                    _out="$_opt"
                fi
            fi
            _i=$((_i + 1))
        done
    done

    [ -n "$_out" ] || return 1
    printf '%s\n' "$_out"
    return 0
}
