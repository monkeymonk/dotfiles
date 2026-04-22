# Node.js integration.

_runtime_resolve_node_version() {
    RUNTIME_NODE_VERSION=$(node --version 2>/dev/null)
    export RUNTIME_NODE_VERSION
}

runtime_plugin_node() {
    require_cmd node || return 0

    export NODE_ENV="${NODE_ENV:-development}"
    ctx_set_lazy RUNTIME_NODE_VERSION _runtime_resolve_node_version plugin
}

hook_register setup runtime_plugin_node
