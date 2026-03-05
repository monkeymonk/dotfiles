# runtime

Structured, deterministic terminal environment layer.

## Layout

```
runtime/
├── bootstrap.sh          # Single entry point
├── core/                 # Primitives (no tool-specific logic)
├── config/               # Declarative preferences
│   └── machine/          # Host-specific overrides
├── plugins/              # Tool integrations (hook-based)
├── ai/                   # Local LLM tooling (Ollama)
│   ├── data/             # Static tip pool
│   └── integrations/     # Shell integrations (zsh tips)
├── secrets/              # Environment files (*.env)
└── scripts/              # Standalone executables (on PATH)
```

## Bootstrap (Single Entry Point)

`bootstrap.sh` is the only file you source from your shell rc. It:

1. Defines `RUNTIME_ROOT`
2. Guards against double-loading (PID-based)
3. Loads core modules (deterministic order)
4. Loads plugins (register hooks only)
5. Runs `bootstrap` hooks
6. Loads `core/context.sh`
7. Runs `context` hooks
8. Loads config modules (`defaults.sh`, `exports.sh`, `paths.sh`, `context.sh`, `aliases.sh`)
9. Runs `setup` hooks
10. Loads machine overrides
11. Loads secrets (`secrets/*.env`)
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

| Module        | Functions                                                                                                                  | Purpose                                                   |
| ------------- | -------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `env.sh`      | —                                                                                                                          | Safe defaults for `EDITOR`, `PAGER`, `XDG_*`              |
| `log.sh`      | `info`, `success`, `warn`, `error`                                                                                         | TTY-only colorized logging                                |
| `hooks.sh`    | `hook_register`, `hook_run`, `hook_list`                                                                                   | Phase-based hook registry                                 |
| `path.sh`     | `path_prepend`, `path_append`, `path_remove`, `path_dedupe`                                                                | Safe PATH manipulation                                    |
| `prompt.sh`   | `confirm`, `choose_one`, `choose_multi`                                                                                    | Interactive prompts (fzf-aware)                           |
| `system.sh`   | `is_mac`, `is_linux`                                                                                                       | OS detection helpers                                      |
| `utils.sh`    | `has_cmd`, `has_file`, `has_dir`, `require_cmd`, `die`, `try_or_warn`, `safe_source`, `guard_double_load`, `runtime_alias` | General utilities                                         |
| `lazy.sh`     | `lazy_load`                                                                                                                | Deferred command initialization                           |
| `registry.sh` | `registry_init`, `registry_add`, `registry_add_lazy`, `registry_resolve`, `registry_get`, `registry_dump`                  | Tagged key-value registry with lazy evaluation            |
| `context.sh`  | `runtime_context`, `runtime_is_offline`, `ctx_set`, `ctx_set_lazy`                                                         | OS and machine context detection                          |
| `lib.sh`      | —                                                                                                                          | Script bootstrap (logging + utils for standalone scripts) |
| `runtime.sh`  | `runtime_status`                                                                                                           | Runtime diagnostics                                       |

No tool-specific logic belongs here.

## Context Detection

`core/context.sh` exports:

| Variable               | Source                                                    |
| ---------------------- | --------------------------------------------------------- |
| `RUNTIME_OS`           | `uname` → `mac` \| `linux` \| `unknown`                   |
| `RUNTIME_HOST`         | `hostname -s`                                             |
| `RUNTIME_DISTRO`       | `/etc/os-release` ID field                                |
| `SHELL_FAMILY`         | `zsh` \| `bash` \| `sh`                                   |
| `RUNTIME_IS_WORK`      | Machine classification (see below)                        |
| `RUNTIME_IS_HOME`      | Machine classification (see below)                        |
| `RUNTIME_IS_CI`        | `CI`, `GITHUB_ACTIONS`, `GITLAB_CI`, `TRAVIS`, `CIRCLECI` |
| `RUNTIME_IS_CONTAINER` | `/.dockerenv`, `DOCKER_CONTAINER`, `/proc/1/cgroup`       |
| `RUNTIME_SESSION_TYPE` | `x11` \| `wayland` \| `tty` \| `mir`                      |
| `RUNTIME_IS_SERVER`    | Linux + TTY session + no DISPLAY/WAYLAND_DISPLAY          |
| `RUNTIME_IS_SSH`       | `SSH_CLIENT` or `SSH_TTY` present                         |
| `RUNTIME_IS_OFFLINE`   | Lazy probe via `runtime_is_offline` (1s ping timeout)     |

Machine classification priority:

1. `RUNTIME_MACHINE_TYPE` or `RUNTIME_CONTEXT` env vars
2. `$RUNTIME_ROOT/context` dotfile containing `work` or `home`
3. Hostname pattern fallback (anchored: `work`, `work-*`, `*-work`)

## Config (Declarative)

`config/` expresses preferences only:

- `defaults.sh`: user defaults (no conditionals)
- `exports.sh`: pure environment exports (locale, `LESS`, `XDG_*` — no logic)
- `paths.sh`: base PATH entries (system, user, toolchain)
- `context.sh`: context-derived exports (`CLI_OPEN_CMD`, `CLI_PKG_MGR`)
- `aliases.sh`: 60+ shell aliases (git, fs, network, process, power)
- `machine/*.sh`: machine-specific overrides loaded from context

## Secrets

All `secrets/*.env` files are sourced if the directory exists. Load order is
alphabetical. Errors are visible in the shell.

## Plugins (Tool Integrations)

`plugins/` contains tool-specific configuration. Each plugin must:

- Guard with `require_cmd` for tool integrations
- Register hook functions instead of executing work at load time
- Avoid heavy commands at startup
- Use `path_prepend`/`path_append` for tool-specific PATH when needed

Plugins are loaded before context/config; use hooks to run code at the right phase.
To disable a plugin, rename it to `.name.sh` (dotfiles are ignored by the loader).

### Alias Capture (alx)

When [alx](https://github.com/monkeymonk/alx) is installed, `plugins/alx.sh` overrides the `alias` builtin with a shim that persists every alias definition into the alx registry while still creating the real shell alias. At the `interactive` phase, it sweeps any aliases defined before the shim was active (external tools, other rc files). This makes alx a transparent drop-in — existing code can keep using `alias` normally.

### Available Plugins

| Plugin         | Tool                                             | Hook Phase             |
| -------------- | ------------------------------------------------ | ---------------------- |
| `alx.sh`       | Alias management (alx)                           | bootstrap, interactive |
| `bun.sh`       | Bun runtime                                      | setup                  |
| `cdx.sh`       | Directory navigation (cdx)                       | interactive            |
| `composer.sh`  | PHP Composer                                     | setup                  |
| `deno.sh`      | Deno runtime                                     | setup                  |
| `docker.sh`    | Docker                                           | setup                  |
| `uv.sh`        | UV Python package manager                        | setup                  |
| `eza.sh`       | Modern ls replacement                            | setup                  |
| `fzf.sh`       | Fuzzy finder (fd integration)                    | setup                  |
| `ghcup.sh`     | Haskell (GHCup)                                  | setup                  |
| `git.sh`       | Git aliases                                      | setup                  |
| `go.sh`        | Go lang                                          | setup                  |
| `lm-studio.sh` | LM Studio                                        | setup                  |
| `neovim.sh`    | Neovim (EDITOR/VISUAL/SUDO_EDITOR, SSH fallback) | setup                  |
| `node.sh`      | Node.js                                          | setup                  |
| `nvm.sh`       | Node version manager (lazy)                      | setup                  |
| `ollama.sh`    | Ollama LLM (loads ai/ module)                    | setup                  |
| `opencode.sh`  | VS Code                                          | setup                  |
| `pnpm.sh`      | PNPM package manager                             | setup                  |
| `rust.sh`      | Rust / Cargo                                     | setup                  |
| `shell.sh`     | Shell-specific config                            | interactive            |
| `starship.sh`  | Starship prompt                                  | interactive            |
| `tmux.sh`      | Tmux (auto-attach)                               | interactive            |
| `zsh.sh`       | Zsh-specific config                              | interactive            |

### Hook Phases

Available phases (in order):

`bootstrap`, `context`, `setup`, `post_secrets`, `interactive`

Register a hook with:

```sh
hook_register <phase> <function_name>
```

## AI Tooling (Ollama Integration)

The `ai/` module is loaded via `plugins/ollama.sh` when `ollama` is on PATH. Provides 30+ LLM helper commands.

### Model Configuration

| Variable              | Default                   | Purpose             |
| --------------------- | ------------------------- | ------------------- |
| `OLLAMA_MODEL`        | `qwen2.5-coder:7b`        | General / default   |
| `OLLAMA_MODEL_CODE`   | `qwen3-coder:30b`         | Code generation     |
| `OLLAMA_MODEL_REASON` | `qwen3.5:35b`             | Reviews / reasoning |
| `OLLAMA_MODEL_FAST`   | `qwen3.5:9b-q4_K_M`       | Quick tasks         |
| `OLLAMA_MODEL_OCR`    | `glm-ocr:latest`          | OCR                 |
| `OLLAMA_MODEL_VISION` | `llama3.2-vision:11b`     | Image analysis      |
| `OLLAMA_MODEL_EMBED`  | `nomic-embed-text:latest` | Embeddings          |
| `OLLAMA_MODEL_THINK`  | `lfm2.5-thinking:latest`  | Deep thinking       |
| `OLLAMA_MODEL_FLASH`  | `glm-4.7-flash:latest`    | Flash inference     |

### Commands

- **Code:** `llm-explain`, `llm-summary`, `llm-arch`, `llm-refactor`, `llm-optimize`, `llm-security`, `llm-test`, `llm-doc`, `llm-convert`
- **Git:** `llm-review`, `llm-commit`
- **Shell:** `llm-cmd`, `llm-explain-cmd`
- **Debug:** `llm-debug`, `llm-fix`, `llm-implement`
- **Vision:** `llm-ocr`, `llm-vision`
- **Embedding:** `llm-embed`
- **Inference:** `llm-think`, `llm-flash`, `llm-flash-file`
- **Meta:** `llm-help`

### Dynamic Shell Tips (zsh)

When idle for 8 seconds, displays contextual tips:

- Static pool from `ai/data/tips.txt`
- Dynamic tips generated via `tips-generate-ollama` (Ollama-powered, project-aware)
- Only triggers for project directories (detected by `is-project-dir`)
- 70/30 weight favoring dynamic tips
- Force refresh with `tips-refresh [dir]`
- Configurable: `ZSH_TIPS_DYNAMIC`, `ZSH_TIPS_GENERATOR`, `ZSH_TIPS_DYNAMIC_TTL`
- Caching via `cache-run`

## Scripts

`scripts/` contains executable, self-contained commands prepended to `PATH`.

Scripts can bootstrap logging and utils via `core/lib.sh`:

```sh
. "${0%/*}/../core/lib.sh"
```

| Script                 | Purpose                                            |
| ---------------------- | -------------------------------------------------- |
| `benchurl`             | URL benchmark timing                               |
| `cache-run`            | Caching wrapper with configurable TTL              |
| `clipboard`            | Copy: `stdin \| clipboard`; Paste: `clipboard get` |
| `diagnose-zle`         | ZLE diagnostics                                    |
| `is-project-dir`       | Check if a directory is a project root (exit 0/1)  |
| `project-context`      | Extract project metadata                           |
| `recent`               | Show recently modified files                       |
| `serve`                | Simple HTTP server                                 |
| `tips-generate-ollama` | Generate dynamic shell tips via Ollama             |
| `tips-refresh`         | Force-regenerate Ollama tips: `tips-refresh [dir]` |
| `update-system`        | System package manager updates                     |

## Dependencies

| Dependency                               | Required    | Purpose                                        |
| ---------------------------------------- | ----------- | ---------------------------------------------- |
| [alx](https://github.com/monkeymonk/alx) | Recommended | Alias management (drop-in `alias` replacement) |
| [cdx](https://github.com/monkeymonk/cdx) | Optional    | Directory navigation hooks                     |
| [Ollama](https://ollama.com)             | Optional    | Local LLM (enables `ai/` module)               |

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

Introspection:

```sh
runtime_status       # Show RUNTIME_ROOT, context, and hooks
runtime_context      # Show context registry (--scope, --resolve)
hook_list [phase]    # List registered hooks
```

## Adding a Plugin

Create `plugins/myplugin.sh`:

```sh
_myplugin_setup() {
    require_cmd mytool || return 0
    guard_double_load RUNTIME_MYPLUGIN_LOADED || return 0
    runtime_alias myalias 'mytool --flag' --desc "..." --tags "..."
}
hook_register setup _myplugin_setup
```
