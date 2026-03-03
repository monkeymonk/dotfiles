runtime_plugin_zsh() {
  if [ "${SHELL_FAMILY-}" = "zsh" ]; then
    safe_source "${RUNTIME_ROOT}/ai/integrations/zsh-tips.zsh"
  fi
}

hook_register interactive runtime_plugin_zsh
