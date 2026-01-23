# CLI Environment

## Overview
This directory (`$HOME/.config/cli`) is a shell-agnostic CLI environment.

- Portable across macOS / Linux (Arch, Ubuntu, etc.)
- Shared across shells (zsh first, bash supported; fish planned)
- Shells are thin adapters: they only source `start.sh`

## Directory Layout
- `start.sh` - main entrypoint (source this from .zshrc/.bashrc)
- `bootstrap.sh` - OS/shell detection, PATH setup
- `env/` - environment facts (`*.env`, exports only)
- `defaults/` - opinionated tool defaults
- `lib/` - reusable shell logic (functions only)
- `aliases/` - typing shortcuts (aliases only)
- `shells/` - shell-specific interactive behavior
- `bin/` - personal CLI tools
- `secrets/` - optional private exports

## Load Order
Implemented by `start.sh`:

1. `bootstrap.sh` (OS/shell detection, PATH)
2. `env/` (`env/base.env` -> `env/dev.env` -> `env/os/$OS.env` -> `env/os/$DISTRO.env` -> `env/host/$HOST.env`)
3. `secrets/secrets.env` (optional)
4. `defaults/`
5. `lib/`
6. `aliases/` (interactive only)
7. `shells/<shell>/` (interactive only)

## Installation (Bash / Zsh)

This setup is activated by sourcing `~/.config/cli/start.sh` from your shell startup files.

### Zsh

Add this to `~/.zshrc`:

```sh
# CLI environment
[ -f "$HOME/.config/cli/start.sh" ] && . "$HOME/.config/cli/start.sh"
```

If you want it for login shells as well, also add the same line to `~/.zprofile`.

### Bash

Add this to `~/.bashrc`:

```sh
# CLI environment
[ -f "$HOME/.config/cli/start.sh" ] && . "$HOME/.config/cli/start.sh"
```

If you want it for login shells too, also add the same line to `~/.bash_profile` (or `~/.profile`).

### Notes

- Interactive-only configuration (aliases + `shells/<shell>/`) loads only when the shell is interactive.
- If you use tmux autostart, you can temporarily disable it for debugging with `TMUX=1`.

## Machine & OS Integration
- OS detection uses `uname` and `/etc/os-release`.
- OS-specific exports live in `env/os/`.
- Host-specific overrides live in `env/host/<hostname>.env`.

Example paths:

- `~/.config/cli/env/os/macos.env`
- `~/.config/cli/env/os/linux.env`
- `~/.config/cli/env/host/jungle-mobile.env`

## Environment Variables
These are the stable variables this setup defines.

### Core
- `CLI_HOME` (start.sh, guaranteed): this config directory
- `OS` (bootstrap, guaranteed): `macos`, `linux`, or `unknown`
- `DISTRO` (bootstrap, optional): Linux distro id from `/etc/os-release` (e.g. `arch`)
- `HOST` (bootstrap, best-effort): short hostname
- `HAS_OLLAMA` (bootstrap, optional): `1` if `ollama` is available

### XDG
- `XDG_CONFIG_HOME` (defaults, guaranteed)
- `XDG_DATA_HOME` (defaults, guaranteed)
- `XDG_CACHE_HOME` (defaults, guaranteed)

### Tooling
- `EDITOR` (defaults, guaranteed)
- `VISUAL` (defaults, guaranteed)
- `SUDO_EDITOR` (defaults, guaranteed)
- `PAGER` (defaults, guaranteed)
- `MANPAGER` (defaults, optional; set when `nvim` is available)
- `FZF_DEFAULT_COMMAND` (defaults, guaranteed)

### Ollama
- `OLLAMA_HOST` (defaults, optional)
- `OLLAMA_NUM_PARALLEL` (defaults, optional)
- `OLLAMA_MAX_LOADED_MODELS` (defaults, optional)
- `OLLAMA_LOG_LEVEL` (defaults, optional)
- `OLLAMA_GPU_OVERHEAD` (defaults, optional)

### Dev Tool Roots
- `NVM_DIR` (env, guaranteed)
- `PYENV_ROOT` (env, guaranteed)
- `PNPM_HOME` (env, guaranteed)

## Secrets
- `secrets/secrets.env` is optional and never committed.
- Copy `secrets/secrets.example.env` to `secrets/secrets.env` and fill values.

## Adding New Logic
- New env var (facts) -> `env/`
- New default (policy) -> `defaults/`
- Reusable logic -> `lib/`
- Typing shortcuts -> `aliases/`
- Shell UX / hooks / prompt -> `shells/<shell>/`
- New CLI tool -> `bin/`
