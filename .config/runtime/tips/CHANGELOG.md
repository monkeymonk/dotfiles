# Changelog

## Unreleased

### Changed
- Paths are now XDG-aware. `TIPS_DATA_DIR` and `TIPS_CACHE_DIR` resolve to
  `$XDG_DATA_HOME/tips` / `$XDG_CACHE_HOME/tips` when those vars are set,
  otherwise to `$TIPS_CONFIG_DIR/{data,cache}`.
- Default `TIPS_DATA_FILE` is now `$TIPS_DATA_DIR/tips.txt` (was hardcoded
  to a path inside the parent runtime repo). **Breaking** for users who
  relied on the old default — set `TIPS_DATA_FILE` explicitly to keep the
  old location.
- `llm` provider rewritten as a multi-backend dispatcher with auto-detection.
  Now supports OpenAI-compatible endpoints (covers OpenAI, OpenRouter, Groq,
  Together, llama.cpp `llama-server`, Ollama, vLLM, LM Studio), the native
  Anthropic API, and a `custom` external-command backend. `curl` + `jq`
  required for API backends; provider self-skips if missing.
- Installer now ships a default `tips.txt` (60+ terminal power-user tips),
  installs `integrations/`, supports `--local`, `--uninstall`, and respects
  `TIPS_VERSION` / `TIPS_REPO_OWNER` overrides.
- Repo is fully self-contained: no references to the parent runtime layout,
  helpers, or cache namespace.

### Added
- `url` provider — fetch tips from one or more HTTP(S) sources with
  configurable TTL. Disabled until `TIPS_URL_SOURCES` is set.
- `integrations/zsh-idle.zsh` — opt-in idle-prompt tip widget for zsh, with
  Alt+k to apply the visible tip to the edit buffer.
- `examples/provider-template.sh` — copy-paste template for custom providers.
- `data/tips.txt` — curated default tips (terminal power-user audience).
- GitHub Actions CI: shellcheck + bats on bash & zsh, Linux + macOS.
- `EXTRACTION.md` — guide for splitting this directory into its own repo.

## v0.1.0
- Core `tips` command with pluggable provider system.
- Weighted random tip selection across providers.
- Built-in providers: `static` (file-based), `llm` (LLM-generated per project).
- Subcommands: `list`, `count`, `refresh`, `status`, `sources`, `edit`.
- Provider interface: `name`, `list`, `weight`, `generate`, `status`, `edit_path`.
- User providers via `~/.config/tips/providers/`.
- Bash and Zsh compatible (sourced or executed directly).
- Installer script for standalone setup.
