# Extracting `tips` to a standalone repository

This project currently lives inside a parent dotfiles/runtime repo. To ship
it as its own repository without losing history:

## 1. Choose extraction strategy

| Tool | When | Notes |
|---|---|---|
| `git subtree split` | History only goes back as far as `tips/` was a clean subtree (no cross-cutting commits) | Built-in to git, lossless, fast. |
| `git filter-repo` | History includes commits that touch both `tips/` and other paths and you want to retain only the `tips/` subset | Modern replacement for `filter-branch`. Install: `pip install git-filter-repo`. |

If unsure, try `subtree split` first — it's reversible.

## 2. Extract with `git subtree split`

From a fresh clone of the parent repo:

```bash
cd /path/to/parent-repo
git subtree split --prefix=tips -b tips-only
git checkout tips-only
# now HEAD only contains tips/ history, with paths re-rooted
```

Push to a new repo:

```bash
gh repo create monkeymonk/tips --public --source=. --remote=origin --push
# or:
git remote add origin git@github.com:monkeymonk/tips.git
git push -u origin tips-only:main
```

## 3. Extract with `git filter-repo` (alternative)

```bash
git clone --no-local /path/to/parent-repo tips-extracted
cd tips-extracted
git filter-repo --subdirectory-filter tips
git remote add origin git@github.com:monkeymonk/tips.git
git push -u origin main
```

## 4. First-release checklist

In the new standalone repo:

- [ ] Update `install.sh` `TIPS_REPO_OWNER` default if your fork lives elsewhere.
- [ ] Run `./tests/bats/bin/bats tests` — must pass with no parent repo on disk.
- [ ] Run `./install.sh --local` in a clean `HOME` (e.g. inside a Docker container) and verify the post-install state matches `tips status` expectations.
- [ ] Verify the curl-pipe install path by hosting a copy of `install.sh` and running it from a fresh shell:
  ```bash
  TIPS_REPO_OWNER=youruser bash <(curl -fsSL https://.../install.sh)
  ```
- [ ] Tag the first release (`git tag v0.1.0 && git push --tags`). The installer will pick it up automatically via the GitHub tags API.
- [ ] Update `CHANGELOG.md` with a "v0.1.0 — extracted from runtime" entry.
- [ ] Confirm CI passes on the new repo (Linux + macOS, bash + zsh).
- [ ] Re-record `demo.tape` if any output strings changed during extraction.

## 5. Migrating the parent runtime repo

The parent repo currently does:

```sh
safe_source "${RUNTIME_ROOT}/tips/tips.sh"
```

…and ships its own `ai/integrations/zsh-tips.zsh`. Two options for the
post-extraction wiring:

### Option A: install via the public installer (recommended)

In the runtime repo's setup hook (e.g. a one-time install step):

```sh
if ! command -v tips >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/monkeymonk/tips/main/install.sh \
    | TIPS_NO_RC_PATCH=1 bash
fi
```

Then in `plugins/tips.sh` (or wherever the runtime registers tip behavior):

```sh
runtime_plugin_tips() {
  has_cmd tips || return 0
  # tips.sh self-installs to ~/.local/bin/; source it explicitly to get the
  # `tips` shell function (not just the binary on PATH).
  safe_source "$HOME/.local/bin/tips.sh"
  # Optional: the idle widget
  safe_source "$TIPS_CONFIG_DIR/integrations/zsh-idle.zsh"
}
hook_register setup runtime_plugin_tips
```

Drop `ai/integrations/zsh-tips.zsh` (replaced by the upstream
`integrations/zsh-idle.zsh`). Drop `scripts/tips-generate` and
`scripts/tips-refresh` — the new `llm` provider auto-detects local backends
without them, and supports a `custom` backend if you want to keep the
script as an external generator.

### Option B: git submodule

```sh
git submodule add https://github.com/monkeymonk/tips.git tips
```

Keep the existing `safe_source "${RUNTIME_ROOT}/tips/tips.sh"` line. Pin
to a tag with `git -C tips checkout v0.1.0`.

This option avoids the network dependency at install time but requires a
submodule update step.

## 6. What to remove from the parent repo after extraction

- `tips/` directory (or replace with a submodule pointer)
- `ai/integrations/zsh-tips.zsh` (replaced by `integrations/zsh-idle.zsh` in tips repo)
- `scripts/tips-generate`, `scripts/tips-refresh` (only if no other code calls them)
- Any `RUNTIME_ROOT`-relative path references that pointed into the old `tips/` data layout
