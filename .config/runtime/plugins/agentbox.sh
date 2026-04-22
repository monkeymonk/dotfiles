# AgentBox integration — run AI tools in isolated Docker containers.
#
# Overrides claude, codex, gemini, opencode to route through agentbox.
# Provides localclaude, localcodex, localgemini, localopencode for native access.

runtime_plugin_agentbox() {
    has_cmd agentbox || return 0
    has_cmd docker || return 0

    guard_double_load RUNTIME_AGENTBOX_LOADED || return 0

    alias claude='agentbox claude --' \
        --desc "Claude Code via agentbox" --tags "ai,agentbox,claude"
    alias codex='agentbox codex --' \
        --desc "Codex via agentbox" --tags "ai,agentbox,codex"
    alias gemini='agentbox gemini --' \
        --desc "Gemini CLI via agentbox" --tags "ai,agentbox,gemini"
    alias opencode='agentbox opencode --' \
        --desc "OpenCode via agentbox" --tags "ai,agentbox,opencode"

    # Native (local) access — bypasses agentbox, runs host binary directly.
    alias localclaude='command claude' \
        --desc "Claude Code (native, no agentbox)" --tags "ai,claude,local"
    alias localcodex='command codex' \
        --desc "Codex (native, no agentbox)" --tags "ai,codex,local"
    alias localgemini='command gemini' \
        --desc "Gemini CLI (native, no agentbox)" --tags "ai,gemini,local"
    alias localopencode='command opencode' \
        --desc "OpenCode (native, no agentbox)" --tags "ai,opencode,local"
}

hook_register setup runtime_plugin_agentbox
