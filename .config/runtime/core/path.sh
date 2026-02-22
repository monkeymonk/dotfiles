# Centralized PATH manipulation.

path_remove() {
    _target=$1
    [ -n "$_target" ] || return 0

    _old_ifs=$IFS
    IFS=:
    _new_path=""
    for _p in $PATH; do
        if [ "$_p" != "$_target" ] && [ -n "$_p" ]; then
            if [ -n "$_new_path" ]; then
                _new_path="$_new_path:$_p"
            else
                _new_path="$_p"
            fi
        fi
    done
    IFS=$_old_ifs
    PATH="$_new_path"
    unset _old_ifs _new_path _p _target
}

path_prepend() {
    _dir=$1
    [ -n "$_dir" ] || return 0
    path_remove "$_dir"
    if [ -n "$PATH" ]; then
        PATH="$_dir:$PATH"
    else
        PATH="$_dir"
    fi
    unset _dir
}

path_append() {
    _dir=$1
    [ -n "$_dir" ] || return 0
    path_remove "$_dir"
    if [ -n "$PATH" ]; then
        PATH="$PATH:$_dir"
    else
        PATH="$_dir"
    fi
    unset _dir
}
