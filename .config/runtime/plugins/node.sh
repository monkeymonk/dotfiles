# Node.js integration.

runtime_plugin_node() {
    require_cmd node || return 0

    export NODE_ENV="${NODE_ENV:-development}"
}

runtime_hook_register setup runtime_plugin_node
