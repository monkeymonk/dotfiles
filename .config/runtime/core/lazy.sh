# lazy.sh — lazy_load utility
# Usage: lazy_load <loader_fn> <cmd1> [cmd2 ...]
#
# Creates a stub for each cmd. On first call of any stub:
#   1. Unsets ALL stubs registered in this batch
#   2. Runs loader_fn
#   3. Re-executes the original command with original args

lazy_load() {
  local loader_fn="$1"
  shift
  local cmds=("$@")

  # Build the unset/unfunction call with all cmd names (baked in at registration time)
  local unset_cmd
  if [ -n "$ZSH_VERSION" ]; then
    unset_cmd="unfunction ${cmds[*]}"
  else
    unset_cmd="unset -f ${cmds[*]}"
  fi

  local cmd
  for cmd in "${cmds[@]}"; do
    # Each stub captures: loader_fn, unset_cmd, and its own cmd name
    eval "
${cmd}() {
  ${unset_cmd}
  ${loader_fn}
  ${cmd} \"\$@\"
}
"
  done
}
