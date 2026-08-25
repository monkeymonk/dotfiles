# Contributing

Thanks for contributing to `tips`.

## Development setup

- Source `tips.sh` to load the function into your shell:
  - `source tips.sh`
- Test commands:
  - `tips`
  - `tips status`
  - `tips list --source static`

## Tests

Run the full test suite:

```sh
./tests/bats/bin/bats tests
```

Run a focused test file:

```sh
./tests/bats/bin/bats tests/test_core.bats
```

## Style

- Bash/Zsh compatible; keep indentation to 2 spaces.
- Public functions use the `tips_` prefix (e.g., `tips_register_provider`).
- Internal helpers use the `_tips_` prefix (e.g., `_tips_pcall`).
- Providers expose `tips_provider_<name>_*` functions.
- Internal globals use the `__TIPS_` prefix.

## Safety

`tips.sh` is sourced into a user's shell. Avoid setting global `set -euo pipefail` in it,
since that would change the user's shell behavior. Use local guards in functions instead.

**Zsh pitfall:** Never declare `local` variables inside loops — zsh prints the old value
on re-declaration. Always declare locals at the top of the function.

## Writing a provider

Create a file in `providers/` (built-in) or `~/.config/tips/providers/` (user):

```bash
# providers/myprovider.sh
tips_provider_myprovider_name() { echo "My Provider"; }
tips_provider_myprovider_weight() { echo 50; }
tips_provider_myprovider_list() {
  echo "tip one"
  echo "tip two"
}
tips_register_provider myprovider
```

Optional methods: `generate [dir]`, `status`, `edit_path`.

## Releases

- Commit messages follow Conventional Commits (`feat:`, `fix:`, `chore:`).
- When incrementing a release tag, update `CHANGELOG.md` in the same change.

Release process:

1. Bump `__TIPS_VERSION` at the top of `tips.sh`.
2. Move "Unreleased" entries in `CHANGELOG.md` under a new version heading.
3. `git commit -m "release: vX.Y.Z"` and `git tag vX.Y.Z`.
4. `git push origin main --tags`. CI runs against the tag.
5. The installer's `_latest_tag` lookup picks up the new tag automatically.

The installer accepts `TIPS_VERSION=vX.Y.Z` to pin to a specific release.

## License

By contributing, you agree that your contributions are licensed under the MIT License.
