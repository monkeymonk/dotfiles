# Docker integration.

runtime_plugin_docker() {
    has_cmd docker || return 0

    export DOCKER_BUILDKIT="${DOCKER_BUILDKIT:-1}"
}

runtime_hook_register post_config runtime_plugin_docker
