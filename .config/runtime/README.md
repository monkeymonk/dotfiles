# runtime

Structured, deterministic terminal environment layer.

## Layout

```
runtime/
├── bootstrap.sh          # Single entry point
├── core/                 # Primitives (no tool-specific logic)
├── config/               # Declarative preferences
├── plugins/              # Tool integrations (hook-based)
├── ai/                   # Local LLM tooling (llama.cpp / Ollama)
│   ├── data/             # Static tip pool
│   └── integrations/     # Shell integrations (zsh tips)
├── tips/                 # Pluggable tip aggregator (static + LLM providers)
├── secrets/              # Environment files (*.env)
├── scripts/              # Commands meant to be typed (on PATH, cmdx catalog)
└── libexec/              # Internal helpers (on PATH, not cataloged)
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
12. Prepends `libexec/` then `scripts/` to `PATH`
13. Sources `cdx` if installed
14. Runs `interactive` hooks
15. Deduplicates `PATH`

Load order is strict:

`core → plugins → [bootstrap] → context → [context] → config → [setup] → secrets → [post_secrets] → scripts → cdx → [interactive]`

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
| `ai-capabilities.sh` | Activate generated AI tooling bundle (`~/Works/tools/ai-capabilities`) | setup                  |
| `ai.sh`              | Local LLM tooling (paths, symlinks, backend-agnostic)                  | setup                  |
| `alx.sh`             | Alias management (alx)                                                 | bootstrap, interactive |
| `amdgpu.sh`          | AMD GPU/NPU env (ROCm gfx1150 override, NPU detection)                 | setup                  |
| `atuin.sh`           | Atuin — SQLite shell history (dir/session scoping, opt-in sync); owns `^R` + up | interactive       |
| `bitwarden.sh`       | Bitwarden — official CLI (`bw`) and optional Rust client (`rbw`)       | setup                  |
| `bun.sh`             | Bun runtime                                                            | setup                  |
| `cal.sh`             | Calendar/contacts — khal + vdirsyncer                                  | setup                  |
| `cdx.sh`             | Directory navigation (cdx)                                             | interactive            |
| `cherrylab.sh`       | CherryLab docker stack wrapper (`cherrylab` CLI)                       | setup                  |
| `composer.sh`        | PHP Composer                                                           | setup                  |
| `deno.sh`            | Deno runtime                                                           | setup                  |
| `docker.sh`          | Docker (contributes `RUNTIME_DOCKER_RUNNING`)                          | setup                  |
| `eza.sh`             | Modern `ls` replacement                                                | setup                  |
| `fzf.sh`             | Fuzzy finder (fd integration)                                          | setup                  |
| `ghcup.sh`           | Haskell (GHCup)                                                        | setup                  |
| `git.sh`             | Git aliases (contributes `RUNTIME_GIT_VERSION`)                        | setup                  |
| `go.sh`              | Go lang                                                                | setup                  |
| `huggingface.sh`     | Hugging Face Hub CLI (`HF_HOME`, auth)                                 | setup                  |
| `llama.sh`           | llama.cpp (`llama-cli`, `llama-server`, `llama-swap`)                  | setup                  |
| `mail.sh`            | Mail stack — aerc + isync (mbsync) + notmuch                           | setup                  |
| `mise.sh`            | mise — polyglot version manager                                        | setup                  |
| `neovim.sh`          | Neovim (EDITOR/VISUAL/SUDO_EDITOR, SSH fallback)                       | setup                  |
| `nvim-scratch.sh`    | Persistent nvim scratchpad (`nvim-scratch` service); contributes `RUNTIME_SCRATCH_RUNNING` (via socket count) | setup |
| `node.sh`            | Node.js (contributes `RUNTIME_NODE_VERSION`)                           | setup                  |
| `ollama.sh`          | Ollama (`OLLAMA_HOST`, `OLLAMA_MODELS`, daemon aliases)                | setup                  |
| `omp.sh`             | oh-my-pi (`omp`) coding agent — cached shell completions               | interactive            |
| `open.sh`            | Cross-platform `open` shim (Linux fallback via xdg-open)               | setup                  |
| `pnpm.sh`            | PNPM package manager                                                   | setup                  |
| `rust.sh`            | Rust / Cargo                                                           | setup                  |
| `shell.sh`           | Shell-specific interactive config                                      | interactive            |
| `ssh.sh`             | Forces `TERM=xterm-256color` for `ssh` invocations                     | setup                  |
| `starship.sh`        | Starship prompt                                                        | interactive            |
| `tmux.sh`            | Tmux (auto-attach)                                                     | interactive            |
| `uv.sh`              | UV Python package manager                                              | setup                  |
| `workenv.sh`         | workenv — Dockerized portable development workspace                    | setup                  |
| `yazi.sh`            | Yazi file manager + `y` cd-on-exit wrapper                             | setup                  |
| `zsh.sh`             | Zsh-specific interactive config                                        | interactive            |

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

`tips/` is a pluggable tip aggregator (sourced by `plugins/zsh.sh` from `tips/tips.sh`). Providers under `tips/providers/` contribute weighted tips from independent sources:

- **static** — pool from `ai/data/tips.txt`
- **llm** — project-aware tips generated via `tips-generate` (uses the active backend: llama.cpp or Ollama), gated by `is-project-dir`, refreshable via `tips-refresh [dir]`

The `ai/integrations/zsh-tips.zsh` integration shows a tip on idle (8s default).

Commands once sourced: `tips`, `tips list [--source X]`, `tips count`, `tips refresh [--source X]`, `tips status`. See `tips/README.md` for provider authoring and config (`TIPS_CONFIG_DIR`, weighting).

## Scripts

Two directories, both prepended to `PATH`:

- **`scripts/`** — commands meant to be typed. This is the only directory the
  `cmdx` catalog reads (`~/.config/cmdx/config.toml`), so anything here shows up
  in `cmdx list`, `cmdx <TAB>` and the picker.
- **`libexec/`** — internal helpers: invoked by name from plugins, keybinds and
  other scripts, or run by hand rarely enough that they are noise in a catalog.
  On `PATH` exactly like `scripts/`, never cataloged.

Moving a file between the two is the whole mechanism — `cmdx` has no ignore
list, and every caller in this repo resolves helpers by name via `PATH`, not by
directory. `libexec/` sits at the same depth as `scripts/`, so `core/lib.sh`
bootstrapping keeps working unchanged:

```sh
. "${0%/*}/../core/lib.sh"
```

### `scripts/` — cataloged commands

| Script            | Purpose                                                       |
| ----------------- | -------------------------------------------------------------- |
| `benchurl`        | URL benchmark timing                                          |
| `cherrylab`       | Manage the CherryLab docker stack and project compose files   |
| `clipboard`       | Copy: `stdin \| clipboard`; Paste: `clipboard get`             |
| `notify`          | Alert when a long job ends: popup, sound, tmux bell            |
| `nvim-scratch`    | Persistent nvim scratchpad service: `attach`, `open`, `eval`, `stop`, `status`, `doctor`, `toggle`/`close` (tmux) |
| `project-context` | Extract project metadata                                      |
| `recent`          | Open the most recently modified file                          |
| `serve`           | Simple HTTP server                                             |
| `system-checkup`  | Write a machine configuration snapshot to a file               |
| `term`            | Launch `$TERMINAL` (indirection point for keybinds)            |
| `update-system`   | System package manager updates                                 |

### `libexec/` — internal helpers

| Helper                | Purpose                                                             | Called by                     |
| --------------------- | ------------------------------------------------------------------- | ----------------------------- |
| `aerc-harden-creds`   | Replace plaintext aerc passwords with `rbw get` lookups (Bitwarden) | by hand, rarely               |
| `ai-symlinks-refresh` | Symlink AI CLIs from non-standard paths into `~/.local/bin`         | `plugins/ai.sh`               |
| `cache-run`           | Caching wrapper with configurable TTL                               | `zsh-tips.zsh`, `tips-refresh`|
| `is-project-dir`      | Check if a directory is a project root (exit 0/1)                   | `tips-generate`               |
| `tips-generate`       | Generate dynamic shell tips (ollama or llama.cpp)                   | `zsh-tips.zsh`, `tips-refresh`|
| `tips-refresh`        | Force-regenerate dynamic tips: `tips-refresh [dir]`                 | by hand                       |
| `yazi-launch`         | Run yazi and emit final cwd                                         | `plugins/yazi.sh`, niri `Mod+F`|

#### nvim-scratch Service Architecture

**Full documentation:** [docs/nvim-scratch/README.md](docs/nvim-scratch/README.md)

`nvim-scratch` provides a tmux-independent service API for a long-running Neovim server with on-demand UI attachment:

**Service vs. UI (tmux) Boundary:**
- **Service (core):** One persistent headless Neovim instance (`--headless --listen`) per named scratchpad, spawned by `nvim-scratch` and surviving shell/tmux/pane closure.
- **UI (tmux helper):** Presentation is owned by `${XDG_CONFIG_HOME:-$HOME/.config}/tmux/scripts/nvim-scratch-toggle`, which handles tmux float/popup geometry, pane naming, and tmux-specific lifecycle. The `toggle` and `close` commands are tmux-only and rely on this helper.

**Terminology:**
- **Attach:** UI client connects to a running server via `--server`/`--remote-ui`; closing the client detaches the UI without stopping the server.
- **Detach:** User command `:detach` (or closing the pane) drops the UI while the server keeps running.
- **Quit:** `:q` inside the client quits the server itself (same as in any Neovim session).

**Core Commands:**
- `nvim-scratch attach [NAME]` — Ensure server for NAME, attach a UI in the current terminal (blocking). NAME defaults to `scratch`.
- `nvim-scratch open [--name NAME] FILE...` or `nvim-scratch open NAME -- FILE...` — Ensure server, open files via `--remote`; relative paths become absolute from caller cwd. Examples: `nvim-scratch open README.md`, `nvim-scratch open --name notes 'file with spaces.md'`, or `nvim-scratch open notes -- file.md`.
- `nvim-scratch eval EXPR` or `nvim-scratch eval NAME EXPR` — Execute Neovim expression in running server, print output, return status (e.g., `nvim-scratch eval scratch 'getcwd()'`). Requires already-live server (does not spawn).
- `nvim-scratch stop [NAME]` — Quit the server for NAME, remove its socket.
- `nvim-scratch status` — List live instances (one line per instance).
- `nvim-scratch doctor` — Environment + per-instance diagnostics.
- `nvim-scratch toggle [NAME]` (tmux only) — Toggle a floating pane/popup running `attach`.
- `nvim-scratch close [NAME]` (tmux only) — Close the surface if open; no-op otherwise.

**Socket & State:**
- Sockets stored in `$XDG_RUNTIME_DIR/nvim-scratch/` (mode 0700) for security: msgpack-RPC is unauthenticated code execution, so only the user's own processes can connect. When `XDG_RUNTIME_DIR` is unset, falls back to `${TMPDIR:-/tmp}/nvim-scratch-$(id -u)/`. Existing socket directories must already be current-user-owned non-symlink mode 0700 (no automatic repair into trust).
- State (markdown notes) at `~/.local/state/nvim-scratch/NAME.md` (or `${XDG_STATE_HOME:-...}`).
- Dedicated `~/.cache/nvim-scratch/NAME/main.shada` preserves marks/registers independently.
- Server strips `TMUX`/`TMUX_PANE` env vars at spawn to prevent pane-aware plugins from targeting stale pane IDs.

**Stale Socket Detection:**
- The plugin's `RUNTIME_SCRATCH_RUNNING` detection counts socket files via cheap file-type check (no server probe during shell startup).
- Stale socket files from crashed servers can remain in the socket directory.
- `RUNTIME_SCRATCH_RUNNING` conservatively reports `yes` if any `.sock` node exists; lifecycle commands `attach`, `open`, and `stop` clean stale sockets when they run.

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
