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
5. Runs context hooks, then loads context
6. Runs config hooks, then loads config modules (including `config/paths.sh` and `config/context.sh`)
7. Loads machine overrides
8. Loads secrets
9. Prepends `scripts/` to `PATH`
10. Exports aliases via `alx`
11. Sources `cdx` if installed
12. Runs late hooks

Load order is strict:

`core → plugins → pre_context → context → post_context → pre_config → config → post_config → machine → secrets → post_secrets → scripts → post_scripts → alx/cdx → late`

## Core (Primitives)

The `core/` layer provides safe primitives only:

- `context.sh`: OS and machine context (`RUNTIME_OS`, `RUNTIME_HOST`, `RUNTIME_DISTRO`, `RUNTIME_IS_WORK`, `RUNTIME_IS_HOME`)
- `env.sh`: safe defaults for `EDITOR`, `PAGER`, `XDG_*`
- `hooks.sh`: hook registry (`runtime_hook_register`, `runtime_hook_run`)
- `system.sh`: helpers like `is_mac`, `has_cmd`
- `path.sh`: `path_prepend`, `path_append`, `path_remove`
- `log.sh`: `info`, `warn`, `error` with TTY-only output
- `prompt.sh`: `confirm`, `choose_one`, `choose_multi` (fzf if present)
- `utils.sh`: `die`, `safe_source`, `guard_double_load`, `require_cmd`

No tool-specific logic belongs here.

## Config (Declarative)

`config/` expresses preferences only:

- `defaults.sh`: user defaults (no conditionals)
- `exports.sh`: pure environment exports (no logic)
- `paths.sh`: base PATH entries (no tool-specific logic)
- `context.sh`: context-derived exports (OS/distro/host)
- `machine/*.sh`: machine-specific overrides loaded from context

## Secrets

All `secrets/*.sh` files are sourced if the directory exists. Load order is
alphabetical. Errors are visible in the shell.

## Plugins (Tool Integrations)

`plugins/` contains tool-specific configuration. Each plugin must:

- Guard with `require_cmd` for tool integrations
- Register hook functions instead of executing work at load time
- Avoid aliases
- Avoid heavy commands at startup
- Use `path_prepend`/`path_append` for tool-specific PATH when needed

Plugins should export environment variables or define helper functions only.
Plugins are loaded before context/config; use hooks to run code at the right phase.
To disable a plugin, rename it to `.name.sh` (dotfiles are ignored by the loader).

### Hook Phases

Available phases (in order):

`pre_context`, `post_context`, `pre_config`, `post_config`, `post_secrets`, `post_scripts`, `late`

Register a hook with:

```sh
runtime_hook_register <phase> <function_name>
```

Plugins must explicitly register hook functions using `runtime_hook_register`.

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
