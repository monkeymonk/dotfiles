# Centralized PATH manipulation.

path_remove() {
    local _target _target_norm _old_ifs _path_list _new_path _p _p_norm
    _target=$1
    [ -n "$_target" ] || return 0

    _target_norm=$_target
    while [ "${_target_norm%/}" != "$_target_norm" ] && [ "$_target_norm" != "/" ]; do
        _target_norm=${_target_norm%/}
    done

    _old_ifs=$IFS
    IFS=:
    if [ -n "${ZSH_VERSION-}" ]; then
        _path_list=${=PATH}
    else
        _path_list=$PATH
    fi
    _new_path=""
    for _p in $_path_list; do
        [ -n "$_p" ] || continue
        _p_norm=$_p
        while [ "${_p_norm%/}" != "$_p_norm" ] && [ "$_p_norm" != "/" ]; do
            _p_norm=${_p_norm%/}
        done
        if [ "$_p" != "$_target" ] && [ "$_p_norm" != "$_target_norm" ]; then
            if [ -n "$_new_path" ]; then
                _new_path="$_new_path:$_p"
            else
                _new_path="$_p"
            fi
        fi
    done
    IFS=$_old_ifs
    PATH="$_new_path"
}

path_prepend() {
    local _dir
    _dir=$1
    [ -n "$_dir" ] || return 0
    path_remove "$_dir"
    if [ -n "$PATH" ]; then
        PATH="$_dir:$PATH"
    else
        PATH="$_dir"
    fi
}

path_append() {
    local _dir
    _dir=$1
    [ -n "$_dir" ] || return 0
    path_remove "$_dir"
    if [ -n "$PATH" ]; then
        PATH="$PATH:$_dir"
    else
        PATH="$_dir"
    fi
}

# Remove duplicate entries from PATH while preserving order.
path_dedupe() {
    local _old_ifs _path_list _new_path _seen _p _p_norm
    _old_ifs=$IFS
    IFS=:
    if [ -n "${ZSH_VERSION-}" ]; then
        _path_list=${=PATH}
    else
        _path_list=$PATH
    fi
    _new_path=""
    _seen=":"
    for _p in $_path_list; do
        [ -n "$_p" ] || continue
        _p_norm=$_p
        while [ "${_p_norm%/}" != "$_p_norm" ] && [ "$_p_norm" != "/" ]; do
            _p_norm=${_p_norm%/}
        done
        case "$_seen" in
            *":$_p_norm:"*) continue ;;
        esac
        _seen="${_seen}${_p_norm}:"
        if [ -n "$_new_path" ]; then
            _new_path="$_new_path:$_p"
        else
            _new_path="$_p"
        fi
    done
    IFS=$_old_ifs
    PATH="$_new_path"
}
