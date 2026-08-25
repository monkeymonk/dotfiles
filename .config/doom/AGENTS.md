# Repository Guidelines

## Project Overview

Personal Doom Emacs configuration (`$DOOMDIR`). This repo is *not* Doom
itself — Doom's source lives at `~/.config/emacs`. It is a small, buildless,
literate Emacs Lisp config: no package.json/Makefile/CI, no `.git` in this
directory, no test suite. Environment: GNU Emacs 30.2, PGTK/Wayland,
native-comp, tree-sitter.

Most files exist to **port and adapt an equivalent Neovim config**
(`~/.config/nvim/lua/...`) into Doom idioms — file headers and inline
comments routinely say "mirrors nvim/lua/config/X" or "port of
nvim/lua/util/Y.lua", and give the *reason* a value was chosen, not just the
value. Preserve that commenting style when editing.

## Architecture & Data Flow

Three-layer load chain, always in this order:

```
init.el          -- selects Doom modules (the `(doom! ...)` block)
   |
packages.el      -- declares packages Doom's modules don't already provide
   |
config.el        -- thin entry point; loads each lisp/*.el in fixed order:
   |                 env -> ui -> lsp -> format -> lang-php -> lang-web -> tools
lisp/*.el        -- one file per concern, narrow delta-only tuning on top
                    of whatever the enabled Doom modules already default to
```

Load-order matters and is intentional:
- `lisp/env.el` runs **unconditionally at top level** (not inside a hook or
  `after!`) because `lsp-mode` probes `executable-find` during early
  startup — PATH must be correct before anything else loads.
- `lisp/lsp.el` depends on `env.el`'s PATH/mason wiring and on
  `lisp/lang-php.el`'s `+php/install-stubs` (stub directory referenced by
  `+lsp-php-stub-paths`).
- `lisp/format.el` and `lisp/lang-php.el` coordinate on `web-mode` without
  duplicating logic: `lang-php.el` registers the Blade engine on `web-mode`;
  `format.el`'s `+format-web-mode-set-formatter-h` (on `web-mode-hook`)
  inspects the filename to special-case `.blade.php` formatting.
- Defaults-then-override pattern: `lisp/ui.el` sets `tab-width 2` /
  `indent-tabs-mode nil` globally; `lisp/lang-php.el` relies on php-mode's
  built-in PSR-12-compatible indent style instead of overriding further.

Config style throughout: mostly `after!` blocks (packages are already loaded
via Doom's `:lang`/`:completion`/`:ui` modules in `init.el`; these files only
tune them) plus occasional `use-package!` for extra packages declared in
`packages.el`. Very little raw `setq` outside `after!`/`use-package!` scoping.

## Key Directories

| Path | Purpose |
|---|---|
| `lisp/env.el` | `exec-path`/PATH setup (mise, composer, mason, go, local bin), projectile project-root markers |
| `lisp/ui.el` | fonts, theme (catppuccin mocha), line numbers, scroll margins, evil split/undo options, indent defaults |
| `lisp/lsp.el` | lsp-mode core tuning, per-client config (lsp-ui, PHP/intelephense, Tailwind), manual `docker-compose-langserver` client registration |
| `lisp/format.el` | apheleia formatters + flycheck linters, PHP formatter priority (pint > php-cs-fixer > lsp), Blade-vs-web-mode formatter dispatch |
| `lisp/lang-php.el` | PHP/Laravel/Blade/WordPress: artisan runner, tinker, Blade view/component navigation, PHP stub (intelephense) installer |
| `lisp/lang-web.el` | JS/TS/CSS/web-mode, `node_modules/.bin` PATH wiring, dotenv, markdown reveal-on-edit minor mode, visual-fill-column |
| `lisp/tools.el` | docker(-compose), dape (debugger, incl. Docker Xdebug config), claude-code-ide, wakatime, rest-client, tmux |
| `snippets/` | yasnippet templates — currently **empty**; `:editor snippets` module is enabled but nothing authored here yet |
| `.claude/` | Claude Code tool-permission settings (`settings.json` project-level, `settings.local.json` personal overrides) |

## Development Commands

| Changed | Required action |
|---|---|
| `init.el`, `packages.el` | `~/.config/emacs/bin/doom sync`, then **restart Emacs** |
| `config.el`, `lisp/*.el` | `SPC h r r` (`doom/reload`) or restart |
| anything affecting fonts | open a **new frame** — reload alone is not enough |

```sh
timeout 300 ~/.config/emacs/bin/doom sync     # apply init.el/packages.el changes
timeout 300 ~/.config/emacs/bin/doom doctor   # diagnose env/package problems
~/.config/emacs/bin/doom info                 # dump Doom's environment info
```

`doom sync` is cheap (seconds) when nothing changed — don't hesitate to run
it. Always wrap it in `timeout` in automation (it can hang waiting on
network/build steps).

There is no lint/test/build command — this is a config, not a program. The
closest thing to CI is a headless load + a live-frame probe (see Testing &
QA).

## Code Conventions & Common Patterns

- **File header**: `;;; $DOOMDIR/lisp/X.el -*- lexical-binding: t; -*-` plus
  a purpose comment, often citing the nvim file being ported.
- **Naming**: private/internal helpers `+<domain>--name` (e.g.
  `+env--mise-node-bin`, `+php--blade-resolve`); public/interactive commands
  `+<domain>/name` (e.g. `+php/artisan`, `+markdown-appear-mode` is the
  exception as a minor mode); hook functions suffixed `-h` (e.g.
  `+format-php-set-formatter-h`), added via `add-hook!`/`add-hook`.
- **Scoping**: wrap package config in `(after! <package> ...)`; use
  `use-package!` only for packages declared in `packages.el` that need
  `:init`/`:hook`/`:config` staging (e.g. `claude-code-ide`, `wakatime-mode`,
  `visual-fill-column`).
- **Graceful degradation over error handling**: guard optional external
  tools with `executable-find`/`file-exists-p`/`file-directory-p` and no-op
  (or fall back) rather than `condition-case`. Example:
  `lisp/lsp.el`'s docker-compose-langserver client only registers
  `(when (executable-find "docker-compose-langserver") ...)`.
  `lisp/tools.el`'s `wakatime-mode` is entirely skipped unless both the CLI
  and `~/.wakatime.cfg` exist.
- **Idempotent list/vector mutation**: dedupe before pushing —
  `+env/prepend-to-path` checks both `exec-path` and split PATH before
  adding; `lisp/lsp.el`'s intelephense stub config uses `seq-contains-p` +
  `vconcat` before appending to a vector setting.
  `flycheck-add-next-checker` chaining in `format.el` is re-run on every
  `lsp-managed-mode-hook` fire and documented as safe because the function
  itself dedupes.
- **Keybindings**: `map!` blocks live at the end of the relevant `lisp/*.el`
  file (not in `ui.el`/`lsp.el`/`env.el`, which never bind keys), scoped with
  `:after <mode>` + `:localleader :map <mode>-map`, each entry carrying a
  `:desc` string. Global tool bindings use `:leader (:prefix-map ("a" .
  "claude") ...)` style (see `lisp/tools.el`).
- **Cross-config porting**: when adding new behavior, check whether an
  equivalent already exists in `~/.config/nvim/lua/...` first — most of this
  repo is a deliberate 1:1 port, and new code should follow the same
  approach + explain deviations in a comment.
- **Read Doom's own module source before overriding a setting**: grep
  `~/.config/emacs/sources/doom+/modules/lang/<lang>/config.el` — several
  settings are already Doom defaults (re-setting adds noise or breaks a
  fallback chain). Known already-default cases:
  `markdown-fontify-code-blocks-natively` (`t`), `visual-fill-column`
  (already installed by `:editor word-wrap`, no `package!` needed).

## Important Files

- `config.el` — entry point; the ordered `load!` list here IS the module
  index; adding a new `lisp/*.el` file requires both a `load!` call and a row
  in this file's header comment.
- `init.el` — Doom module selection. Notable non-default flags: `:lang php
  (+lsp +tree-sitter)`, `:lang markdown (+lsp +grip)` — **deliberately no
  `+tree-sitter`** (would remap to `markdown-ts-mode`, which derives from
  `fundamental-mode` and silently breaks every `markdown-mode` variable and
  hook used in `lang-web.el`), `:lang python (+lsp +pyright +tree-sitter
  +uv)`, `:tools (docker +lsp +tree-sitter)`, `:tools (lsp +peek)`, `:tools
  (magit +forge)`, `:editor (format +onsave +lsp)`.
- `packages.el` — extra packages: `catppuccin-theme`, `add-node-modules-path`,
  `dotenv-mode`, `docker-compose-mode`, `eat` (terminal backend used by
  claude-code-ide), `claude-code-ide` (pinned to GitHub recipe
  `manzaltu/claude-code-ide.el`), `wakatime-mode`.
- `lisp/lsp.el` header comment enumerates which LSP clients need **zero**
  config because their mason binary name already matches the lsp-mode client
  id (ts_ls, cssls, html, jsonls, yamlls, bashls, gopls, rust_analyzer,
  pyright, lua_ls, emmet_ls, dockerls) — this file only documents the
  exceptions.
- `CLAUDE.md` (repo root) — the authoritative verification/debugging doctrine
  for this specific config (headless-load traps, buffer-local vs.
  `setq-default` pitfalls, jit-lock/redisplay gotchas, PGTK daemon teardown
  behavior). Read it before debugging a "change didn't apply" report.

## Runtime/Tooling Preferences

- Emacs 30.2, PGTK/Wayland build, native-comp + tree-sitter — assume these
  are present; do not add Emacs-version guards for older releases.
- LSP servers/formatters/linters are managed by **mason** (via lsp-mode),
  with PATH wired in `lisp/env.el`; Node version comes from **mise**
  (`~/.config/mise/config.toml`, parsed manually — no direct mise-emacs
  integration package); Go bin is `~/go/bin`; Composer vendor bins resolve
  project-local first (`vendor/bin/`) then global.
  `lisp/env.el`'s `+env/prepend-to-path` calls are ordered **in reverse
  precedence** (last call = highest PATH priority) — preserve that ordering
  discipline when adding a new PATH entry.
- Terminal integration uses `eat`, not `vterm` (no vterm dependency in this
  repo).
- Docker is used both as a project-root marker (docker-compose.yml/
  compose.yaml) and as an execution target: PHP tests/artisan/tinker route
  through `docker compose exec <container>` when `+php-run-tests-in-docker`
  is set; `dape`'s `xdebug-docker` config maps a configurable
  `+debugger-php-docker-root` (default `/var/www/html`) to the project root.

## Testing & QA

There is no automated test suite — this is a personal editor config.
Verification is manual and **must use a real graphical frame**; a headless
`emacs --batch`/`emacs --daemon` load proves only that the config doesn't
error, not that theme/fonts/faces/frame hooks work (those only materialize on
a graphical frame). Working procedure (see `CLAUDE.md` for full detail and
the 8 documented gotchas):

```sh
emacs --daemon=verify                                   # load errors surface here
emacsclient -s verify -c -n /path/to/fixture.md          # -c = real frame, -n = returns immediately
sleep 5                                                  # let deferred init/font-lock settle
emacsclient -s verify -e '(...probe...)'                 # query LIVE state, not a captured var
emacsclient -s verify -e '(kill-emacs)'                  # always clean up
```

Key traps to avoid false passes/failures (full list in `CLAUDE.md`):
buffer-local variables need `setq-default` + `(default-value 'VAR)` to
verify, not plain `setq`/`VAR`; `font-lock-flush` only marks dirty — call
`(redisplay t)` before asserting fontification; `post-command-hook` never
fires inside `emacsclient -e` — simulate with `(run-hooks
'post-command-hook)`; `doom sync` reporting "up-to-date" does not prove a
package installed — check
`~/.config/emacs/.local/straight/build-30.2/<package>/` directly; a missing
theme silently aborts font application too, so check `*Messages*` for
`Unable to find theme file` before debugging a font issue as separate.

No linter/formatter runs on this repo's own `.el` files (no `.dir-locals.el`
enforcing style here) — match the existing conventions above by hand.
