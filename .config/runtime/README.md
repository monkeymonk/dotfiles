# runtime

Structured, deterministic terminal environment layer.

## Layout

```
runtime/
├── bootstrap.sh          # Single entry point
├── core/                 # Primitives (no tool-specific logic)
├── config/               # Declarative preferences
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
8. Loads config modules (`config.sh`, `paths.sh`, `aliases.sh`)
9. Runs `setup` hooks
10. Loads secrets (`secrets/*.env`)
11. Runs `post_secrets` hooks
12. Prepends `scripts/` to `PATH`
13. Exports aliases via `alx`
14. Sources `cdx` if installed
15. Runs `interactive` hooks
16. Deduplicates `PATH`

Load order is strict:

`core → plugins → [bootstrap] → context → [context] → config → [setup] → secrets → [post_secrets] → scripts → alx/cdx → [interactive]`

Per-machine values (`BROWSER`, `TERMINAL`, etc.) should be `export`ed in your shell rc **before** sourcing `bootstrap.sh` — `core/env.sh` uses `${VAR:=default}` so pre-existing exports win.

## Core (Primitives)

The `core/` layer provides safe primitives only:

| Module        | Functions                                                                                                                  | Purpose                                                   |
| ------------- | -------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `env.sh`      | —                                                                                                                          | Safe defaults for `BROWSER`, `EDITOR`, `VISUAL`, `PAGER`, `XDG_*` |
| `log.sh`      | `info`, `success`, `warn`, `error`                                                                                         | TTY-only colorized logging                                |
| `hooks.sh`    | `hook_register`, `hook_run`, `hook_list`                                                                                   | Phase-based hook registry                                 |
| `path.sh`     | `path_prepend`, `path_append`, `path_remove`, `path_dedupe`                                                                | Safe PATH manipulation                                    |
| `prompt.sh`   | `confirm`, `choose_one`, `choose_multi`                                                                                    | Interactive prompts (fzf-aware)                           |
| `system.sh`   | `is_mac`, `is_linux`                                                                                                       | OS detection helpers                                      |
| `utils.sh`    | `has_cmd`, `has_file`, `has_dir`, `require_cmd`, `die`, `try_or_warn`, `safe_source`, `guard_double_load`                  | General utilities                                         |
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
| `RUNTIME_IS_CI`        | `CI`, `GITHUB_ACTIONS`, `GITLAB_CI`, `TRAVIS`, `CIRCLECI` |
| `RUNTIME_IS_CONTAINER` | `/.dockerenv`, `DOCKER_CONTAINER`, `/proc/1/cgroup`       |
| `RUNTIME_SESSION_TYPE` | `x11` \| `wayland` \| `tty` \| `mir`                      |
| `RUNTIME_IS_SERVER`    | Linux + TTY session + no DISPLAY/WAYLAND_DISPLAY          |
| `RUNTIME_IS_SSH`       | `SSH_CLIENT` or `SSH_TTY` present                         |
| `RUNTIME_IS_OFFLINE`   | Lazy probe via `runtime_is_offline` (1s ping timeout)     |

## Config (Declarative)

`config/` expresses preferences only:

- `config.sh`: user defaults, locale/pager exports, XDG dirs, and context-derived values (`CLI_OPEN_CMD`, `CLI_PKG_MGR`)
- `paths.sh`: base PATH entries (system, user, toolchain)
- `aliases.sh`: 60+ shell aliases (git, fs, network, process, power)

## Secrets

All `secrets/*.env` files are sourced if the directory exists. Load order is
alphabetical. Errors are visible in the shell.

## Plugins (Tool Integrations)

`plugins/` contains tool-specific configuration. Each plugin must:

- Gate with `has_cmd` (silent) or `require_cmd` (warns when missing); the convention is `has_cmd` for optional tools
- Register hook functions instead of executing work at load time
- Avoid heavy commands at startup
- Use `path_prepend`/`path_append` for tool-specific PATH when needed
- Optionally contribute to the context registry via `ctx_set_lazy <VAR> <resolver_fn> plugin`

Plugins are loaded before context/config; use hooks to run code at the right phase.
To disable a plugin, rename it to `.name.sh` (dotfiles are ignored by the loader).

### Alias Capture (alx)

When [alx](https://github.com/monkeymonk/alx) is installed, `plugins/alx.sh` overrides the `alias` builtin with a shim that persists every alias definition into the alx registry while still creating the real shell alias. At the `interactive` phase, it sweeps any aliases defined before the shim was active (external tools, other rc files). This makes alx a transparent drop-in — existing code can keep using `alias` normally.

### Available Plugins

| Plugin           | Tool                                                      | Hook Phase             |
| ---------------- | --------------------------------------------------------- | ---------------------- |
| `agentbox.sh`    | AgentBox — AI tools in isolated Docker containers         | setup                  |
| `ai.sh`          | Local LLM tooling (paths, symlinks, backend-agnostic)     | setup                  |
| `alx.sh`         | Alias management (alx)                                    | bootstrap, interactive |
| `bun.sh`         | Bun runtime                                               | setup                  |
| `cdx.sh`         | Directory navigation (cdx)                                | interactive            |
| `composer.sh`    | PHP Composer                                              | setup                  |
| `deno.sh`        | Deno runtime                                              | setup                  |
| `docker.sh`      | Docker (contributes `RUNTIME_DOCKER_RUNNING`)             | setup                  |
| `eza.sh`         | Modern `ls` replacement                                   | setup                  |
| `fzf.sh`         | Fuzzy finder (fd integration)                             | setup                  |
| `ghcup.sh`       | Haskell (GHCup)                                           | setup                  |
| `git.sh`         | Git aliases (contributes `RUNTIME_GIT_VERSION`)           | setup                  |
| `go.sh`          | Go lang                                                   | setup                  |
| `huggingface.sh` | Hugging Face Hub CLI (`HF_HOME`, auth)                    | setup                  |
| `llama.sh`       | llama.cpp (`llama-cli`, `llama-server`, `llama-swap`)     | setup                  |
| `mise.sh`        | mise — polyglot version manager                           | setup                  |
| `neovim.sh`      | Neovim (EDITOR/VISUAL/SUDO_EDITOR, SSH fallback)          | setup                  |
| `node.sh`        | Node.js (contributes `RUNTIME_NODE_VERSION`)              | setup                  |
| `open.sh`        | Cross-platform `open` shim (Linux fallback via xdg-open)  | setup                  |
| `pnpm.sh`        | PNPM package manager                                      | setup                  |
| `rust.sh`        | Rust / Cargo                                              | setup                  |
| `shell.sh`       | Shell-specific interactive config                         | interactive            |
| `starship.sh`    | Starship prompt                                           | interactive            |
| `tmux.sh`        | Tmux (auto-attach)                                        | interactive            |
| `uv.sh`          | UV Python package manager                                 | setup                  |
| `zsh.sh`         | Zsh-specific interactive config                           | interactive            |

### Hook Phases

Available phases (in order):

`bootstrap`, `context`, `setup`, `post_secrets`, `interactive`

Register a hook with:

```sh
hook_register <phase> <function_name>
```

## AI Tooling (Local LLMs)

The `ai/` module provides backend-agnostic `llm-*` helpers that dispatch between **llama.cpp / llama-swap** and **Ollama** at call time. Loaded by `plugins/ai.sh` when any of `ollama`, `llama-server`, or `llama-swap` is on PATH. `plugins/llama.sh` handles llama.cpp-specific detection (GPU backend, `LLAMA_HOST`, `LLAMA_MODELS_DIR`, `llama-swap` wiring).

### Backend Selection

| Variable        | Default | Purpose                                                         |
| --------------- | ------- | --------------------------------------------------------------- |
| `AI_BACKEND`    | `auto`  | `auto` (llama-swap if up, else ollama) / `llama` / `ollama`     |
| `AI_AUTOSTART`  | `1`     | Auto-start llama-swap in the background on first use (0 = off)  |
| `LLAMA_HOST`    | `127.0.0.1:8080`  | llama.cpp / llama-swap OpenAI-compat endpoint         |
| `OLLAMA_HOST`   | `127.0.0.1:11434` | Ollama endpoint                                       |

`plugins/llama.sh` also exports `LLAMA_GPU_BACKEND` (detected: `metal`/`cuda`/`rocm`/`vulkan`/`cpu`) and `LLAMA_MODELS_DIR` (`~/.local/share/llama.cpp/models`).

### Role → Model Mapping

A single `AI_MODEL_*` namespace is used for both backends. Values are either llama-swap aliases (from `~/.config/llama-swap/config.yaml`) or Ollama tags (e.g. `qwen2.5-coder:7b`), depending on the active backend.

| Variable            | Default    | Purpose                                |
| ------------------- | ---------- | -------------------------------------- |
| `AI_MODEL_DEFAULT`  | `default`  | General-purpose                        |
| `AI_MODEL_CODE`     | `code`     | Heavy code generation / refactor       |
| `AI_MODEL_REASON`   | `reason`   | Reviews, debug, security audits        |
| `AI_MODEL_FAST`     | `fast`     | Commit messages, short explanations    |
| `AI_MODEL_EMBED`    | `embed`    | Embeddings                             |
| `AI_MODEL_VISION`   | `vision`   | Image analysis (backend must support)  |
| `AI_MODEL_OCR`      | `ocr`      | OCR (backend must support)             |

### Commands

- **Code understanding:** `llm-explain`, `llm-explain-edit`, `llm-summary`, `llm-arch`
- **Git:** `llm-review`, `llm-review-edit`, `llm-commit`
- **Shell:** `llm-cmd`, `llm-explain-cmd`
- **Code quality:** `llm-refactor`, `llm-refactor-edit`, `llm-optimize`, `llm-optimize-edit`, `llm-security`
- **Testing / docs:** `llm-test`, `llm-test-edit`, `llm-doc`, `llm-doc-edit`
- **Debug / development:** `llm-debug`, `llm-fix`, `llm-implement`, `llm-convert`, `llm-api-client`, `llm-code`
- **Vision / embed:** `llm-ocr`, `llm-vision`, `llm-embed`
- **Inference:** `llm-think`, `llm-flash`, `llm-flash-file`
- **Meta:** `llm-help`

The `*-edit` variants open the result in Neovim (often in a split). Aliases are only registered when `alx` is present.

### Dynamic Shell Tips (zsh)

When idle for 8 seconds, displays contextual tips:

- Static pool from `ai/data/tips.txt`
- Dynamic tips generated via `tips-generate` (project-aware, uses whichever LLM backend is live — ollama or llama.cpp)
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
| `is-project-dir`       | Check if a directory is a project root (exit 0/1)  |
| `project-context`      | Extract project metadata                           |
| `recent`               | Show recently modified files                       |
| `serve`                | Simple HTTP server                                 |
| `tips-generate`        | Generate dynamic shell tips (ollama or llama.cpp)  |
| `tips-refresh`         | Force-regenerate dynamic tips: `tips-refresh [dir]`|
| `update-system`        | System package manager updates                     |

## Dependencies

| Dependency                                             | Required    | Purpose                                                    |
| ------------------------------------------------------ | ----------- | ---------------------------------------------------------- |
| [alx](https://github.com/monkeymonk/alx)               | Recommended | Alias management (drop-in `alias` replacement)             |
| [cdx](https://github.com/monkeymonk/cdx)               | Optional    | Directory navigation hooks                                 |
| [llama.cpp](https://github.com/ggml-org/llama.cpp)     | Optional    | Local LLM inference (preferred backend via `llama-server`) |
| [llama-swap](https://github.com/mostlygeek/llama-swap) | Optional    | Model-router proxy in front of llama.cpp                   |
| [Ollama](https://ollama.com)                           | Optional    | Alternate LLM backend                                      |

Any one of llama.cpp / llama-swap / Ollama is enough to activate the `ai/` module.

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
runtime_status                   # Show RUNTIME_ROOT, context, and hooks
runtime_context                  # Show full context registry (resolves lazy entries)
runtime_context --scope system   # system | session | plugin — filter by source tag
hook_list [phase]                # List registered hooks
```

## Adding a Plugin

Create `plugins/myplugin.sh`. Convention: hook target is `runtime_plugin_<name>`, gated by `has_cmd` (silent). Use `require_cmd` only when a missing tool should warn.

```sh
runtime_plugin_myplugin() {
    has_cmd mytool || return 0
    alias myalias='mytool --flag' --desc "..." --tags "..."
}
hook_register setup runtime_plugin_myplugin
```

To contribute to the context registry, define a resolver and register it lazily:

```sh
_runtime_resolve_myplugin_version() {
    RUNTIME_MYPLUGIN_VERSION=$(mytool --version 2>/dev/null)
    export RUNTIME_MYPLUGIN_VERSION
}

runtime_plugin_myplugin() {
    has_cmd mytool || return 0
    ctx_set_lazy RUNTIME_MYPLUGIN_VERSION _runtime_resolve_myplugin_version plugin
}
```

Use `guard_double_load RUNTIME_MYPLUGIN_LOADED || return 0` only when the plugin has side effects that must not repeat on soft reload (path exports, function overrides).
