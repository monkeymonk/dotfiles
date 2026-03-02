# runtime

Structured, deterministic terminal environment layer.

## Layout

```
runtime/
├── bootstrap.sh
├── core/
├── config/
│   └── machine/
├── secrets/
├── plugins/
└── scripts/
```

## Bootstrap (Single Entry Point)

`bootstrap.sh` is the only file you source from your shell rc. It:

1. Defines `RUNTIME_ROOT`
2. Guards against double-loading
3. Loads core modules (deterministic order)
4. Loads plugins (register hooks only)
5. Runs `bootstrap` hooks
6. Loads `core/context.sh`
7. Runs `context` hooks
8. Loads config modules (`defaults.sh`, `exports.sh`, `paths.sh`, `context.sh`, `aliases.sh`)
9. Runs `setup` hooks
10. Loads machine overrides
11. Loads secrets
12. Runs `post_secrets` hooks
13. Prepends `scripts/` to `PATH`
14. Exports aliases via `alx`
15. Sources `cdx` if installed
16. Runs `interactive` hooks
17. Deduplicates `PATH`

Load order is strict:

`core → plugins → [bootstrap] → context → [context] → config → [setup] → machine → secrets → [post_secrets] → scripts → alx/cdx → [interactive]`

## Core (Primitives)

The `core/` layer provides safe primitives only:

- `env.sh`: safe defaults for `EDITOR`, `PAGER`, `XDG_*`
- `log.sh`: `info`, `success`, `warn`, `error` with TTY-only output
- `hooks.sh`: hook registry (`hook_register`, `hook_run`, `hook_list`)
- `path.sh`: `path_prepend`, `path_append`, `path_remove`, `path_dedupe`
- `prompt.sh`: `confirm`, `choose_one`, `choose_multi` (fzf if present)
- `system.sh`: helpers like `is_mac`, `is_linux`
- `utils.sh`: `has_cmd`, `has_file`, `has_dir`, `require_cmd`, `die`, `try_or_warn`, `safe_source`, `guard_double_load`, `runtime_alias`
- `lazy.sh`: `lazy_load` for deferred command initialization
- `registry.sh`: generic tagged key-value registry (`registry_init`, `registry_add`, `registry_add_lazy`, `registry_resolve`, `registry_get`, `registry_dump`)
- `context.sh`: OS and machine context (`RUNTIME_OS`, `RUNTIME_HOST`, `RUNTIME_DISTRO`, `RUNTIME_IS_WORK`, `RUNTIME_IS_HOME`, etc.), plus `runtime_context` and `runtime_is_offline`
- `runtime.sh`: runtime-level diagnostics (`runtime_status`)

No tool-specific logic belongs here.

## Config (Declarative)

`config/` expresses preferences only:

- `defaults.sh`: user defaults (no conditionals)
- `exports.sh`: pure environment exports (no logic)
- `paths.sh`: base PATH entries (no tool-specific logic)
- `context.sh`: context-derived exports (OS/distro/host)
- `aliases.sh`: shell aliases
- `machine/*.sh`: machine-specific overrides loaded from context

## Secrets

All `secrets/*.sh` files are sourced if the directory exists. Load order is
alphabetical. Errors are visible in the shell.

## Plugins (Tool Integrations)

`plugins/` contains tool-specific configuration. Each plugin must:

- Guard with `require_cmd` for tool integrations
- Register hook functions instead of executing work at load time
- Avoid heavy commands at startup
- Use `path_prepend`/`path_append` for tool-specific PATH when needed

Plugins are loaded before context/config; use hooks to run code at the right phase.
To disable a plugin, rename it to `.name.sh` (dotfiles are ignored by the loader).

### Hook Phases

Available phases (in order):

`bootstrap`, `context`, `setup`, `post_secrets`, `interactive`

Register a hook with:

```sh
hook_register <phase> <function_name>
```

Plugins must explicitly register hook functions using `hook_register`.

## Scripts

`scripts/` contains executable, self-contained commands. This directory is
prepended to `PATH` by `bootstrap.sh`.

## Dependencies

`runtime` integrates with:

- `alx` for alias management (required for alias export).
- `cdx` for directory navigation hooks (optional but recommended).

### Install alx

```bash
curl -fsSL https://raw.githubusercontent.com/monkeymonk/alx/main/install.sh | bash
```

### Install cdx

```bash
curl -fsSL https://raw.githubusercontent.com/monkeymonk/cdx/main/install.sh | bash
```

## Usage

Add this to your shell rc:

```bash
[ -f "$HOME/.config/runtime/bootstrap.sh" ] && source "$HOME/.config/runtime/bootstrap.sh"
```

## Debugging

Set `RUNTIME_DEBUG=1` to print per-hook timing to stderr.

Reload options:

```sh
# Soft reload (re-sources in-place, state may linger)
runtime_reload soft

# Hard reload (re-exec shell — clean state)
runtime_reload hard
```
