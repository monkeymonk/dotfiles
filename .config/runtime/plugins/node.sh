# Node.js integration.

runtime_plugin_node() {
    has_cmd node || return 0

    export NODE_ENV="${NODE_ENV:-development}"
}

runtime_hook_register post_config runtime_plugin_node
