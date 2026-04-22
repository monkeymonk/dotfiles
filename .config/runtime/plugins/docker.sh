# Docker integration.

_runtime_resolve_docker_running() {
    if docker info >/dev/null 2>&1; then
        RUNTIME_DOCKER_RUNNING=1
    else
        RUNTIME_DOCKER_RUNNING=0
    fi
    export RUNTIME_DOCKER_RUNNING
}

runtime_plugin_docker() {
    require_cmd docker || return 0

    export DOCKER_BUILDKIT="${DOCKER_BUILDKIT:-1}"
    ctx_set_lazy RUNTIME_DOCKER_RUNNING _runtime_resolve_docker_running plugin
}

hook_register setup runtime_plugin_docker
