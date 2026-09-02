# Tmux key bindings

The help popup is a **live, searchable index of the bindings tmux has actually
loaded** — not a hand-maintained table.

## Open it

```
prefix + h            # prefix is C-a
```

A floating popup shows every annotated binding as a **category-grouped grid**
(columns adapt to the popup width). Type to fuzzy-filter — a query matches a
whole grid row. `Esc` or `Ctrl-c` closes it. Selecting a row does nothing: this
is an informational panel, it never runs the binding.

## How it works

- `scripts/cheatsheet.sh` reads bindings from `tmux list-keys -N` when opened.
  **tmux is the source of truth** — there is no second list to maintain.
- Each of my bindings carries a note of the form:

  ```
  bind-key -N "Category | Description" <key> <command>
  ```

  The script splits the note on ` | ` into a **category** and a **description**.
- The prefix is detected dynamically, so prefix-table shortcuts render as
  `C-a h` and root-table (global) shortcuts render bare, e.g. `M-T`.

## Add a binding to the index

Annotate it in `tmux.conf` and reload (`prefix + r`):

```
bind-key -N "Panes | Swap with the marked pane" b swap-pane
```

It appears in the popup automatically, grouped under its category. The popup
orders groups as: `Sessions`, `Windows`, `Navigation`, `Panes`, `Copy mode`,
`Persistence`, `Configuration`, `Utilities`, `Plugins`, `Workmux`, `Help`
(anything else sorts last). Reuse one of these categories.

## Notes

- Only bindings annotated with the `Category | Description` convention appear.
  The dozens of tmux/plugin **default** bindings that ship their own plain notes
  are intentionally excluded, so the index stays curated rather than a wall of
  keys. To surface a default, annotate it (see below).
- The genuinely useful defaults (zoom, swap/resize pane, list/rename
  session+window, copy mode, …) are annotated in `tmux.conf` so they still show
  up, grouped.
- Plugin keys (`tmux-resurrect` save/restore, `tmux-floax`, `tmux-yank`, TPM)
  are re-declared **after** the `run tpm` line — that is the only place a note
  survives plugin loading. They restate each plugin's own binding verbatim; if a
  plugin renames its scripts, update those lines to match.
- `copy-mode-vi` bindings appear only if I have explicitly annotated them.

## Workmux

| Binding              | Action                                   |
| -------------------- | ---------------------------------------- |
| `prefix + W`         | Toggle the Workmux agent dashboard       |
| `prefix + C-w`       | Toggle the live agent status sidebar     |
| click status segment | Toggle the dashboard                     |

All three are annotated `Workmux | …`, so they also appear in `prefix + h`.

### Status-bar segment

`scripts/workmux_status.sh` feeds a catppuccin-styled module at the left of
`status-right`: `▲n` agents waiting for input (peach), `●n` working
(sapphire), `✓n` done (green); `–` when no agents are tracked, `?` when
workmux or jq cannot be queried. Counts are server-global, like the dashboard.

Two details that are easy to regress:

- The script `cd /` before querying. Status-line jobs inherit the focused
  pane's working directory, and inside a git repo `workmux status` scopes
  itself to that repository and reports no agents at all — the segment showed
  a bare `–` until this was fixed.
- The output is padded to a constant 9 cells (`WIDTH`). `status-right` is
  right-aligned, so a segment that changes width shifts every segment left of
  it on every count change; that shifting was the flicker.

The module is assembled inline instead of via catppuccin's
`utils/status_module.conf`: that helper needs a `%hidden MODULE_NAME`, which
does not survive the `source` while catppuccin is still loading from its own
asynchronous `run`. All references are lazy (`#{E:...}`) so the segment
resolves at draw time regardless of load order. Icon and colour are options
(`@catppuccin_workmux_icon`, `@catppuccin_workmux_color`) — the icon is
nerd-font `md-robot` (U+F06A9).

### Dashboard toggle

`scripts/workmux_dashboard.sh` opens `workmux dashboard` in a centred
**floating pane** (tmux 3.7 `new-pane`), not a popup, and closes it when it is
already open. A popup is a modal overlay: while one is open tmux swallows
every mouse event outside it, so a second click on the status segment can
never reach the binding that would close it — verified by injecting SGR mouse
events into a nested client. A floating pane is an ordinary pane, so the
toggle works.

The pane is found by its title (`wmx-dashboard`) rather than a stored id, so
the toggle is stateless and survives a server restart. `new-pane` takes
absolute cells and has no centring flag, so the script computes 90%×85% and
the offsets itself. A `client-detached` hook closes it so tmux-resurrect never
saves a floating pane it cannot restore.

The segment is wrapped in `#[range=user|wmx]`, and the root
`MouseDown1Status` binding runs the toggle when `#{mouse_status_range}` is
`wmx`, falling back to tmux's default `switch-client -t =` for every other
status click — so clicking windows and the session name still behaves
normally.

### Sidebar + tmux-resurrect

`workmux sidebar` adds a narrow pane to the left of every window. tmux-resurrect
saves those panes, and on restart continuum restores them as dead empty shells
(the workmux process isn't restored) — leftover sidebar splits.

`scripts/sidebar_cleanup.sh` (wired to a `client-attached` hook) fixes this: once
per server, after a restore, it removes leftover sidebar columns — but only while
no live sidebar is active (`@workmux_sidebar_enabled`), and only panes matching
the sidebar signature (full-height, left-edge, narrow ≤50 cols, bare shell, in a
multi-pane window). Verified safe against the tmuxp layouts, none of which use a
narrow-left split. If you move the sidebar to `position: top`, update the script.
