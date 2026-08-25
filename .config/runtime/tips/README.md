# tips

`tips` is an extensible tip aggregator with pluggable providers. It shows
random tips from multiple sources — a curated static file, remote URLs, or
an LLM (local or API-backed) — and is designed to be sourced into your
shell or run as a standalone command.

![tips demo](demo.gif)

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/monkeymonk/tips/main/install.sh | bash
```

What the installer does:

- Installs `tips.sh` to `~/.local/bin/tips.sh`.
- Installs providers to `$XDG_CONFIG_HOME/tips/providers/` (or `~/.config/tips/providers/`).
- Seeds a default `tips.txt` (60+ terminal power-user tips) into the data dir.
- Seeds `config.sh` with commented examples of every setting.
- Adds `source ~/.local/bin/tips.sh` to your shell rc (with confirmation).

After install: restart your shell (or `source` your rc), then run `tips`.

### Manual / from a checkout

```bash
git clone https://github.com/monkeymonk/tips ~/src/tips
cd ~/src/tips
./install.sh --local
```

### Pinning a version

```bash
TIPS_VERSION=v0.1.0 curl -fsSL https://.../install.sh | bash
```

### Uninstall

```bash
~/.local/bin/tips.sh && curl -fsSL https://.../install.sh | bash -s -- --uninstall
# or, from a checkout:
./install.sh --uninstall
```

## Usage

```bash
tips                       # random tip (weighted across providers)
tips list                  # all tips, grouped by provider
tips list --source static  # tips from one provider
tips count                 # per-provider counts
tips refresh               # regenerate tips (providers that support it)
tips refresh --source url  # refresh one provider
tips status                # config, providers, counts, paths
tips sources               # list registered providers
tips edit                  # open static tips file in $EDITOR
tips edit llm              # edit a different provider's source
tips --help
tips --version
```

`tips` works both **sourced** into your shell (`source ~/.local/bin/tips.sh`)
and **executed directly** (`~/.local/bin/tips.sh status`).

## Providers

Each provider is a shell file that implements a small interface and
self-registers. Three are shipped:

| Provider | Default weight | What it does |
|---|---|---|
| `static` | 30 | Reads tips from `$TIPS_DATA_FILE`. Always on after install. |
| `url`    | 0 → 30 | Fetches plain-text tip lists from one or more URLs (off until configured). |
| `llm`    | 0 → 70 | Generates project-aware tips via a chat-completion backend. |

**The `static` provider works out of the box.** `url` activates when you set
`TIPS_URL_SOURCES`. `llm` activates when a backend is detected (see below).

### url provider

Configure one or more sources in `$TIPS_CONFIG_DIR/config.sh`:

```bash
# Whitespace- or newline-separated URLs. Each must serve plain text,
# one tip per line, with `#` comments allowed.
TIPS_URL_SOURCES="
  https://example.com/tips.txt
  https://other.example/team-tips.txt
"
TIPS_URL_TTL=86400        # cache age in seconds (default: 1 day)
TIPS_URL_TIMEOUT=5        # per-request timeout (default: 5s)
```

Caches go in `$TIPS_CACHE_DIR/url/`. Use `tips refresh --source url` to force.

### llm provider

Auto-detects a backend on first use, in this order:

1. Local llama.cpp on `127.0.0.1:8080`
2. Local Ollama on `127.0.0.1:11434`
3. `$OPENAI_API_KEY` → OpenAI
4. `$ANTHROPIC_API_KEY` → Anthropic
5. `$TIPS_LLM_GENERATOR` command (custom external generator)

The detected backend is cached in `$TIPS_CACHE_DIR/llm/backend`. Override
explicitly:

```bash
# OpenAI-compatible (covers OpenAI, OpenRouter, Groq, Together, llama.cpp,
# Ollama, vLLM, LM Studio — anything that speaks /v1/chat/completions)
TIPS_LLM_BACKEND=openai
TIPS_LLM_URL=http://127.0.0.1:8080
TIPS_LLM_MODEL=gpt-4o-mini
TIPS_LLM_API_KEY="$OPENAI_API_KEY"

# Native Anthropic
TIPS_LLM_BACKEND=anthropic
TIPS_LLM_MODEL=claude-haiku-4-5
TIPS_LLM_API_KEY="$ANTHROPIC_API_KEY"

# Custom external command (takes dir as $1, prints tips to stdout)
TIPS_LLM_BACKEND=custom
TIPS_LLM_GENERATOR=tips-generate
```

**Soft dependencies:** `curl` and `jq` are required for the API backends.
The provider self-skips with weight 0 if either is missing.

Caches go in `$TIPS_CACHE_DIR/llm/<hash>` per directory.

### Writing a custom provider

Copy `examples/provider-template.sh` to `$TIPS_CONFIG_DIR/providers/<name>.sh`
and edit. Minimal version:

```bash
tips_provider_fortune_name()   { echo "Fortune"; }
tips_provider_fortune_weight() { command -v fortune >/dev/null && echo 40 || echo 0; }
tips_provider_fortune_list()   { fortune -s | tr '\n' ' '; echo; }
tips_register_provider fortune
```

### Provider interface

| Method | Required | Purpose |
|---|---|---|
| `name`        | yes | Display name |
| `list`        | yes | Print tips, one per line |
| `weight`      | no  | Selection weight 0–100 (default: 50) |
| `generate`    | no  | Refresh tips for `$1` (a directory) |
| `status`      | no  | Print `key=value` diagnostic lines |
| `edit_path`   | no  | Print a file path for `tips edit` |

Register at the end of the file: `tips_register_provider <name>`.

## Configuration

All user config lives under `$TIPS_CONFIG_DIR` (`$XDG_CONFIG_HOME/tips/` or
`~/.config/tips/`):

- `config.sh` — sourced before providers load
- `providers/` — user provider scripts
- `integrations/` — optional shell integrations (see below)

### Environment variables

**Paths** (XDG-aware, fall back to a unified `~/.config/tips/` layout when XDG vars unset):

| Var | Default | Purpose |
|---|---|---|
| `TIPS_CONFIG_DIR` | `$XDG_CONFIG_HOME/tips` | Config + user providers |
| `TIPS_DATA_DIR`   | `$XDG_DATA_HOME/tips` or `$TIPS_CONFIG_DIR/data` | Static tips file |
| `TIPS_CACHE_DIR`  | `$XDG_CACHE_HOME/tips` or `$TIPS_CONFIG_DIR/cache` | Per-provider caches |
| `TIPS_DATA_FILE`  | `$TIPS_DATA_DIR/tips.txt` | Static tips source |

**Per-provider settings** are documented in their headers and in the seed
`config.sh` the installer creates.

## Integrations

### zsh idle-tip widget

Show a tip below the prompt while the shell is idle. Press `Alt+k` to copy
the visible tip into the edit buffer. Add to your `.zshrc` after sourcing
`tips.sh`:

```bash
source ~/.local/bin/tips.sh
source "$TIPS_CONFIG_DIR/integrations/zsh-idle.zsh"
```

Tunables: `TIPS_IDLE_INTERVAL`, `TIPS_IDLE_COLOR`, `TIPS_IDLE_PREFIX`,
`TIPS_IDLE_APPLY_KEY`.

## Troubleshooting

- **`tips: no backend available`** — the LLM provider can't find a backend.
  Check `tips status` for the detected state. Set `TIPS_LLM_BACKEND` and
  the matching URL/model/API-key explicitly, or set
  `TIPS_LLM_BACKEND=none` to silence it.
- **LLM auto-detect picked the wrong backend** — delete the cached
  decision: `rm $TIPS_CACHE_DIR/llm/backend`.
- **`url` provider returns nothing** — `tips refresh --source url` to fetch.
  `tips status` shows fresh/stale counts per source.
- **Tip text wraps weirdly in the idle widget** — the widget uses
  `region_highlight`; long tips at the right margin can render oddly. Trim
  source tips to ~100 chars.

## How it works

1. On load, `tips.sh` resolves paths and sources `$TIPS_CONFIG_DIR/config.sh`.
2. It loads providers from `<install-dir>/providers/*.sh` (dev checkout) and
   `$TIPS_CONFIG_DIR/providers/*.sh` (user). Each provider self-registers.
3. `tips` (no args) picks a provider by weighted random, then a random tip
   from that provider. Providers with weight 0 are skipped.

## Development

```bash
./tests/bats/bin/bats tests          # full suite
./tests/bats/bin/bats tests/test_core.bats   # one file
shellcheck tips.sh providers/*.sh    # lint
```

Bats is vendored under `tests/bats/` — no system install needed.

See [CONTRIBUTING.md](CONTRIBUTING.md) for style and release process.
