# Mail stack: aerc + isync (mbsync) + notmuch.

runtime_plugin_mail() {
    has_cmd mbsync || has_cmd notmuch || has_cmd aerc || return 0

    export MAILDIR="${MAILDIR:-$HOME/Mail}"

    runtime_mail_aliases
}

runtime_mail_aliases() {
    guard_double_load RUNTIME_MAIL_ALIASES_LOADED || return 0

    if has_cmd mbsync && has_cmd notmuch; then
        alias mail-sync='mbsync -a && notmuch new' \
            --desc "Sync all IMAP accounts then index with notmuch" \
            --tags "mail,sync,mbsync,notmuch"
    fi

    has_cmd aerc && alias m='aerc' --desc "aerc mail client" --tags "mail,aerc"
    has_cmd notmuch && alias ms='notmuch search' --desc "notmuch search" --tags "mail,notmuch,search"
}

hook_register setup runtime_plugin_mail
