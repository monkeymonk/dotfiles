# Bitwarden — official CLI (`bw`) and optional Rust client (`rbw`).

runtime_plugin_bitwarden() {
    has_cmd bw || has_cmd rbw || return 0

    has_cmd bw && alias bwu='bw unlock' --desc "Bitwarden unlock vault" --tags "bitwarden,bw"

    if has_cmd rbw; then
        alias rbw-cloud='RBW_PROFILE=cloud rbw' \
            --desc "rbw against the cloud profile" \
            --tags "bitwarden,rbw,cloud"
        alias rbw-selfhosted='RBW_PROFILE=selfhosted rbw' \
            --desc "rbw against the self-hosted profile" \
            --tags "bitwarden,rbw,selfhosted"
    fi
}

hook_register setup runtime_plugin_bitwarden
