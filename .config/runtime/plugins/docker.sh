# Docker integration.

runtime_plugin_docker() {
    require_cmd docker || return 0

    export DOCKER_BUILDKIT="${DOCKER_BUILDKIT:-1}"
}

hook_register setup runtime_plugin_docker
