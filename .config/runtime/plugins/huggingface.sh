# Hugging Face Hub CLI — HF_HOME, auth, short alias.
#
# Detects the `hf` CLI (preferred) or the legacy `huggingface-cli`. Exposes
# HF_HOME under XDG_CACHE_HOME so downloaded repos and auth tokens live in
# a predictable, cleanable place. Adds an `hf` alias when only the legacy
# binary is present so helpers can use the short name uniformly.

runtime_plugin_huggingface() {
    has_cmd hf || has_cmd huggingface-cli || return 0

    # Pin the HF cache under XDG so it's predictable and easy to wipe.
    # The CLI defaults to ~/.cache/huggingface already — this just makes
    # the location explicit and honours a user-set XDG_CACHE_HOME.
    export HF_HOME="${HF_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/huggingface}"

    # The canonical CLI is now `hf`; `huggingface-cli` still works as a
    # shim. Expose `hf` as a short alias when only the legacy binary
    # exists so downstream helpers can assume `hf <subcommand>` uniformly.
    if ! has_cmd hf && has_cmd huggingface-cli; then
        alias hf='huggingface-cli' \
            --desc "Hugging Face CLI (legacy-binary shim)" \
            --tags "hf,ai"
    fi
}

hook_register setup runtime_plugin_huggingface
