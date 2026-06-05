# Calendar/contacts: khal + vdirsyncer.

runtime_plugin_cal() {
    has_cmd vdirsyncer || has_cmd khal || return 0
    runtime_cal_aliases
}

runtime_cal_aliases() {
    guard_double_load RUNTIME_CAL_ALIASES_LOADED || return 0

    has_cmd vdirsyncer && alias cal-sync='vdirsyncer sync' \
        --desc "Sync CalDAV/CardDAV via vdirsyncer" \
        --tags "cal,sync,vdirsyncer"

    has_cmd khal && alias k='khal interactive' --desc "khal calendar TUI" --tags "cal,khal"
    has_cmd khal && alias kl='khal list' --desc "khal upcoming events" --tags "cal,khal,list"

    if has_cmd vdirsyncer && has_cmd mbsync && has_cmd notmuch; then
        alias pim-sync='vdirsyncer sync && mbsync -a && notmuch new' \
            --desc "Sync calendar + mail in one go" \
            --tags "pim,sync"
    fi
}

hook_register setup runtime_plugin_cal
